SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs
KSU_BIN=/data/adb/ksu/bin/
TMPDIR=/data/adb/ksu/susfs4ksu

echo "***************************************"
echo "SUSFS4KSU Userspace tool update script"
echo "***************************************"

download() { busybox wget -T 10 --no-check-certificate -qO - "$1"; }
if command -v curl > /dev/null 2>&1; then
	download() { curl --connect-timeout 10 -Ls "$1"; }
fi

check() { 
    if command -v curl > /dev/null 2>&1; then
        curl -s --max-time 5 --head "$1" > /dev/null 2>&1
    else
        busybox wget --no-check-certificate --timeout=5 --spider -q "$1" > /dev/null 2>&1
    fi
}

TRUSTED_HASHES=/data/adb/modules/susfs4ksu/trusted_hashes.txt
# Solo se aceptan binarios de la nube cuyo sha256 este en trusted_hashes.txt
is_trusted() {
	_h=$(sha256sum "$1" 2>/dev/null | awk '{print $1}')
	[ -n "$_h" ] && awk -v h="$_h" '$1==h{f=1} END{exit !f}' "$2" 2>/dev/null
}

# Instala el binario ya descargado y verificado en ${TMPDIR}/ksu_susfs_remote
susfsupdate() {
	# Get the latest commit message for the susfs binary main.c
	susfs_binary_msg=$(curl -s "https://api.github.com/repos/sidex15/susfs4ksu-binaries/commits?sha=universal-binary&path=main.c&page=1&per_page=1" | grep '"message":' | head -n 1 | sed 's/.*"message": "\(.*\)".*/\1/')
	echo -e "[-] Latest susfs binary message:\n\n$susfs_binary_msg\n"
	chmod +x ${TMPDIR}/ksu_susfs_remote
	if ${TMPDIR}/ksu_susfs_remote > /dev/null 2>&1 ; then
		cp -f ${TMPDIR}/ksu_susfs_remote ${KSU_BIN}/ksu_susfs
		echo "[-] Update Complete!"
	else
		echo "[!] Download Test Failed"
		echo "[!] Update Failed"
	fi
}
# Check connectivity first
echo "[-] Checking susfs binary cloud connection"
base_url="https://raw.githubusercontent.com/sidex15/susfs4ksu-binaries/universal-binary/ksu_susfs_arm64"
if check "$base_url"; then
	echo "[-] susfs binary cloud connection established"
	echo "[-] Checking hash of susfs binaries..."
	hash=$(sha256sum ${SUSFS_BIN} | awk '{print $1}')
	# Download once, then hash and install that same file
	download "$base_url" > ${TMPDIR}/ksu_susfs_remote 2>/dev/null
	cloudhash=$(sha256sum ${TMPDIR}/ksu_susfs_remote | awk '{print $1}')
	if [ "$hash" = "$cloudhash" ]; then
		echo "[-] Local and Cloud Version match, no need to update"
	elif ! is_trusted ${TMPDIR}/ksu_susfs_remote "$TRUSTED_HASHES"; then
		echo "[!] Cloud binary is not in trusted_hashes.txt, update refused"
		echo "[!] Update this module to get newer binaries"
		rm -f ${TMPDIR}/ksu_susfs_remote
		exit 1
	else
		susfsupdate
	fi
	rm -f ${TMPDIR}/ksu_susfs_remote
else
	echo "[!] No internet connection"
	exit 1
fi
