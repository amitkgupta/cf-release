# Assumes ${BOSH_INSTALL_TARGET}
# Note that we do not attempt to handle either colons or quotes in
# paths. Spaces and new-lines in paths should be ok.

(

    find_dirs () {
        local pattern
        local result
        pattern=$@
        result=$(find -L "${BOSH_INSTALL_TARGET}" -maxdepth 1 -type d \
            '(' ${pattern} ')' -exec printf '%s\000' '{}' ';' \
            | sed -e 's/\o000$//' -e 's/\o000/'\'':'\''/g')
        if [ -z "${result}" ]
        then \
            printf ''
        else \
            printf \''%s'\' "${result}"
        fi
    }

    find_dirs_from_files () {
        local pattern
        local result
        pattern=$@
        result=$(find -L "${BOSH_INSTALL_TARGET}" -type f '(' ${pattern} ')' \
            -exec dirname '{}' ';' | sort | uniq \
            | sed -e 's/^/'\''/' -e 's/$/'\''/' | tr '\n' ':' | sed -e 's/:$//')
        printf '%s' "${result}"
    }

    BINDIRS=$(find_dirs -name "bin" -o -name "sbin")
    printf 'export PATH=%s:${PATH}\n' "${BINDIRS}" > "${BOSH_INSTALL_TARGET}/enable"

    LIBDIRS=$(find_dirs_from_files -name '*.so')
    printf 'export LD_LIBRARY_PATH=%s:${LD_LIBRARY_PATH}\n' "${LIBDIRS}" >> "${BOSH_INSTALL_TARGET}/enable"
    printf 'export LIBRARY_PATH=%s:${LIBRARY_PATH}\n' "${LIBDIRS}" >> "${BOSH_INSTALL_TARGET}/enable"

    INCLUDEDIRS1=$(find_dirs -name "include")
    INCLUDEDIRS2=$(find_dirs_from_files -name '*.h')
    printf 'export CPATH=%s:%s:${CPATH}\n' "${INCLUDEDIRS1}" "${INCLUDEDIRS2}" >> "${BOSH_INSTALL_TARGET}/enable"

    PKGCONFIGDIRS=$(find_dirs_from_files -name '*.pc')
    printf 'export PKG_CONFIG_PATH=%s:${PKG_CONFIG_PATH}\n' "${PKGCONFIGDIRS}" >> "${BOSH_INSTALL_TARGET}/enable"

    M4DIRS=$(find_dirs -name 'aclocal*')
    printf 'export ACLOCAL_PATH=%s:${ACLOCAL_PATH}\n' "${M4DIRS}" >> "${BOSH_INSTALL_TARGET}/enable"
)

