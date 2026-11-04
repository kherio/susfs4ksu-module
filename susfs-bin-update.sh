#!/bin/sh
SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs
KSU_BIN=/data/adb/ksu/bin/
TMPDIR=/data/adb/ksu/susfs4ksu
TRUSTED_HASHES=/data/adb/modules/susfs4ksu/trusted_hashes.txt

echo "***************************************"
echo "SUSFS4KSU Userspace tool update script"
echo "***************************************"

download() { busybox wget -T 1 --no-check-certificate -qO - "$1"; }
if command -v curl > /dev/null 2>&1; then
	download() { curl --connect-timeout 1 -Ls "$1"; }
fi

# Solo se aceptan binarios de la nube cuyo sha256 este en trusted_hashes.txt
is_trusted() {
	_h=$(sha256sum "$1" 2>/dev/null | awk '{print $1}')
	[ -n "$_h" ] && awk -v h="$_h" '$1==h{f=1} END{exit !f}' "$2" 2>/dev/null
}

# dl logic, shorthand
# download remote
#    verify hash is trusted; test binary; if fail keep what is installed
if download "https://raw.githubusercontent.com/sidex15/susfs4ksu-binaries/universal-binary/ksu_susfs_arm64" > ${TMPDIR}/ksu_susfs_remote ; then
    if ! is_trusted ${TMPDIR}/ksu_susfs_remote "$TRUSTED_HASHES"; then
		echo "[!] Cloud binary is not in trusted_hashes.txt"
		echo "[!] Update refused, update this module to get newer binaries"
		rm -f ${TMPDIR}/ksu_susfs_remote
		exit 1
    fi
    # test downloaded binary
    chmod +x ${TMPDIR}/ksu_susfs_remote
    if ${TMPDIR}/ksu_susfs_remote > /dev/null 2>&1 ; then
		# test ok
		mv -f ${TMPDIR}/ksu_susfs_remote ${KSU_BIN}/ksu_susfs
		echo "[-] Update Complete!"
    else
		# test failed
		echo "[!] Download Test Failed"
		echo "[!] Update Failed"
        rm -f ${TMPDIR}/ksu_susfs_remote
        exit 1
    fi
else
	# failed
	echo "[!] No internet connection or susfs binaries not found"
	echo "[!] Update Failed"
    exit 1
fi
#EOL
