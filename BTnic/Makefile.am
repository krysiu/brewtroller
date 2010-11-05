## Process this file with automake to produce Makefile.in
## Created by Anjuta

SUBDIRS = src po 

btnicdocdir = ${prefix}/doc/btnic
btnicdoc_DATA = \
	README\
	COPYING\
	AUTHORS\
	ChangeLog\
	INSTALL\
	NEWS


INTLTOOL_FILES = intltool-extract.in \
	intltool-merge.in \
	intltool-update.in

EXTRA_DIST = $(btnicdoc_DATA) \
	$(INTLTOOL_FILES)\
	$(btniccfg_DATA)\
	$(btnicconf_DATA)

DISTCLEANFILES = intltool-extract \
	intltool-merge \
	intltool-update \
	po/.intltool-merge-cache

btnicconf_DATA = \
	btnic.conf

btnicconfdir = \
	/etc

# Remove doc directory on uninstall
uninstall-local:
	-rm -r $(btnicdocdir)
