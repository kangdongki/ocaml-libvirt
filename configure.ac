# ocaml-libvirt
# Copyright (C) 2007-2008 Red Hat Inc., Richard W.M. Jones
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

dnl Process this file with autoconf to produce a configure script.

AC_INIT(ocaml-libvirt,0.6.1.2)

dnl Check for basic C environment.
AC_PROG_CC
AC_PROG_INSTALL
AC_PROG_CPP

AC_C_PROTOTYPES
test "x$U" != "x" && AC_MSG_ERROR(Compiler not ANSI compliant)

AC_PROG_CC_C_O

dnl Select some C flags based on the host type.
AC_CANONICAL_HOST

DEBUG="-g"
WARNINGS="-Wall -Werror"
CFLAGS_FPIC="-fPIC"
WIN32=no
case "$host" in
  *-*-mingw*)
    WARNINGS="$WARNINGS -Wno-unused"
    CFLAGS_FPIC=""
    WIN32=yes
esac
AC_SUBST(DEBUG)
AC_SUBST(WARNINGS)
AC_SUBST(CFLAGS_FPIC)
AC_SUBST(WIN32)

dnl Check for libvirt development environment.
AC_ARG_WITH(libvirt,
	AC_HELP_STRING([--with-libvirt=PATH],[Set path to installed libvirt]),
	[if test "x$withval" != "x"; then
	   CFLAGS="$CFLAGS -I$withval/include"
	   LDFLAGS="$LDFLAGS -L$withval/lib"
	 fi
	])
AC_CHECK_LIB(virt,virConnectOpen,
	[],
	AC_MSG_ERROR([You must install libvirt library]))
AC_CHECK_HEADER([libvirt/libvirt.h],
	[],
	AC_MSG_ERROR([You must install libvirt development package]))

dnl We also use <libvirt/virterror.h>
AC_CHECK_HEADER([libvirt/virterror.h],
	[],
	AC_MSG_ERROR([You must install libvirt development package]))

dnl Check for libvirt >= 0.2.1 (our minimum supported version).
dnl See: http://libvirt.org/hvsupport.html
AC_CHECK_FUNC(virConnectGetCapabilities,
	[],
	AC_MSG_ERROR([You must have libvirt >= 0.2.1]))

dnl Check for optional libvirt functions added since 0.2.1.
dnl See: http://libvirt.org/hvsupport.html
AC_CHECK_FUNCS([virConnectGetHostname \
		virConnectGetURI \
		virDomainBlockStats \
		virDomainGetSchedulerParameters \
		virDomainGetSchedulerType \
		virDomainInterfaceStats \
		virDomainMigrate \
		virDomainSetSchedulerParameters \
		virNodeGetFreeMemory \
		virNodeGetCellsFreeMemory \
		virStoragePoolGetConnect \
		virConnectNumOfStoragePools \
		virConnectListStoragePools \
		virConnectNumOfDefinedStoragePools \
		virConnectListDefinedStoragePools \
		virStoragePoolLookupByName \
		virStoragePoolLookupByUUID \
		virStoragePoolLookupByUUIDString \
		virStoragePoolLookupByVolume \
		virStoragePoolCreateXML \
		virStoragePoolDefineXML \
		virStoragePoolBuild \
		virStoragePoolUndefine \
		virStoragePoolCreate \
		virStoragePoolDestroy \
		virStoragePoolDelete \
		virStoragePoolFree \
		virStoragePoolRefresh \
		virStoragePoolGetName \
		virStoragePoolGetUUID \
		virStoragePoolGetUUIDString \
		virStoragePoolGetInfo \
		virStoragePoolGetXMLDesc \
		virStoragePoolGetAutostart \
		virStoragePoolSetAutostart \
		virStoragePoolNumOfVolumes \
		virStoragePoolListVolumes \
		virStorageVolLookupByName \
		virStorageVolLookupByKey \
		virStorageVolLookupByPath \
		virStorageVolGetName \
		virStorageVolGetKey \
		virStorageVolCreateXML \
		virStorageVolDelete \
		virStorageVolFree \
		virStorageVolGetInfo \
		virStorageVolGetXMLDesc \
		virStorageVolGetPath \
		virDomainBlockPeek \
		virDomainMemoryPeek \
                virDomainGetCPUStats \
])

dnl Check for optional types added since 0.2.1.
AC_CHECK_TYPES([virStoragePoolPtr, virStorageVolPtr],,,
	       [#include <libvirt/libvirt.h>])

dnl Check for basic OCaml environment & findlib.
AC_PROG_OCAML
AC_PROG_FINDLIB

if test "x$OCAMLFIND" = "x"; then
    AC_MSG_ERROR([OCaml findlib is required])
fi

dnl Use ocamlfind to find the required packages ...

dnl Check for required OCaml packages.
AC_CHECK_OCAML_PKG(unix)
if test "x$pkg_unix" != "xyes"; then
    AC_MSG_ERROR([Cannot find required OCaml package 'unix'])
fi

dnl Check for optional NSIS (for building a Windows installer).
dnl XXX This probably doesn't work at the moment XXX
AC_ARG_WITH([nsis],
	[AS_HELP_STRING([--with-nsis],
	    [use NSIS to build a Windows installer])],
	[],
	[with_nsis=no])

MAKENSIS=
LIBVIRT_DLL_PATH=
LIBXDR_DLL_PATH=
LIBXML2_DLL_PATH=
GNUTLS_DLL_PATH=
GTK_PATH=
GTK_DLL_PATH=

[
msys_to_win_dir () {
    eval pushd "\$$1" > /dev/null
    eval $1=`pwd -W`
    popd > /dev/null
}
]

if test "x$with_nsis" != "xno"; then
    AC_PATH_PROG(MAKENSIS,makensis,[],[$with_nsis:$PATH])
    if test "x$MAKENSIS" = "x"; then
	AC_MSG_FAILURE([--with-nsis was given, but could not find MAKENSIS.EXE])
    fi

    # MAKENSIS is set so we will build a rule for making a Windows
    # installer.  To support this, generate wininstaller.nsis.
    saved_IFS=$IFS
    IFS=$PATH_SEPARATOR
    for d in $PATH; do
    	IFS=$saved_IFS
	echo Checking $d for DLLs ... >&5
	if test -f "$d/libvirt-0.dll"; then
	    LIBVIRT_DLL_PATH="$d"
	fi
	if test -f "$d/libxdr.dll"; then
	    LIBXDR_DLL_PATH="$d"
	fi
	if test -f "$d/libxml2-2.dll"; then
	    LIBXML2_DLL_PATH="$d"
	fi
	if test -f "$d/libgpg-error-0.dll"; then
	    GNUTLS_DLL_PATH="$d"
	fi
	if test -f "$d/libgtk-win32-2.0-0.dll"; then
	    GTK_DLL_PATH="$d"
	    GTK_PATH="$d/.."
	fi
    done
    IFS=$saved_IFS

    if test "x$LIBVIRT_DLL_PATH" = "x"; then
    	AC_MSG_FAILURE([cannot find libvirt-0.dll in PATH])
    fi
    if test "x$LIBXDR_DLL_PATH" = "x"; then
    	AC_MSG_FAILURE([cannot find libxdr.dll in PATH])
    fi
    if test "x$LIBXML2_DLL_PATH" = "x"; then
    	AC_MSG_FAILURE([cannot find libxml2-2.dll in PATH])
    fi
    if test "x$GNUTLS_DLL_PATH" = "x"; then
    	AC_MSG_FAILURE([cannot find GnuTLS DLLs in PATH])
    fi
    if test "x$GTK_DLL_PATH" = "x"; then
        AC_MSG_WARN([cannot find GTK DLLs in PATH])
    fi

    # Change the paths to Windows paths.
    msys_to_win_dir LIBVIRT_DLL_PATH
    msys_to_win_dir LIBXDR_DLL_PATH
    msys_to_win_dir LIBXML2_DLL_PATH
    msys_to_win_dir GNUTLS_DLL_PATH
    if test "x$GTK_DLL_PATH" != "x"; then
    	msys_to_win_dir GTK_DLL_PATH
    	msys_to_win_dir GTK_PATH
    fi
fi
AC_SUBST(MAKENSIS)
AC_SUBST(LIBVIRT_DLL_PATH)
AC_SUBST(LIBXDR_DLL_PATH)
AC_SUBST(LIBXML2_DLL_PATH)
AC_SUBST(GNUTLS_DLL_PATH)
AC_SUBST(GTK_DLL_PATH)
AC_SUBST(GTK_PATH)

dnl Summary.
echo "------------------------------------------------------------"
echo "Thanks for downloading" $PACKAGE_STRING
echo "------------------------------------------------------------"

dnl Produce output files.
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES([META
	libvirt/libvirt_version.ml
	Makefile
	Make.rules
	libvirt/Makefile
	examples/Makefile
	])
if test "x$MAKENSIS" != "x"; then
	AC_CONFIG_FILES([wininstaller.nsis])
fi
AC_OUTPUT
