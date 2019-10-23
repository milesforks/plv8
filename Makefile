#-----------------------------------------------------------------------------#
#
# Makefile for v8 static link
#
# 'make' will download the v8 source and build it, then build plv8
# with statically link to v8 with snapshot.  This assumes certain directory
# structure in v8 which may be different from version to another, but user
# can specify the v8 version by AUTOV8_VERSION, too.
#-----------------------------------------------------------------------------#

include Makefile.v8

AUTOV8_DIR = build/v8
AUTOV8_OUT = build/v8/out.gn/x64.release.sample/obj
ICU_STATIC_LIBS = -licui18n -licuuc
AUTOV8_STATIC_LIBS = -lv8_monolith $(ICU_STATIC_LIBS)

ifndef USE_ICU
	AUTOV8_STATIC_LIBS := $(filter-out $(ICU_STATIC_LIBS), $(AUTOV8_STATIC_LIBS))
endif

SHLIB_LINK += -L$(AUTOV8_OUT) -L$(AUTOV8_OUT)/third_party/icu $(AUTOV8_STATIC_LIBS)

include Makefile.shared

ifdef EXECUTION_TIMEOUT
	CCFLAGS += -DEXECUTION_TIMEOUT
endif

ifdef BIGINT_GRACEFUL
	CCFLAGS += -DBIGINT_GRACEFUL
endif

# enable direct jsonb conversion by default
CCFLAGS += -DJSONB_DIRECT_CONVERSION

CCFLAGS += -I$(AUTOV8_DIR)/include -I$(AUTOV8_DIR)
# We're gonna build static link.  Rip it out after include Makefile
SHLIB_LINK := $(filter-out -lv8, $(SHLIB_LINK))

ifeq ($(OS),Windows_NT)
	# noop for now
else
	SHLIB_LINK += -L$(AUTOV8_OUT)
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Darwin)
		CCFLAGS += -stdlib=libc++ -std=c++11
		SHLIB_LINK += -stdlib=libc++
		PLATFORM = x64.release.sample
	endif
	ifeq ($(UNAME_S),Linux)
		ifeq ($(shell uname -m | grep -o arm),arm)
			PLATFORM = arm64.release
		endif
		ifeq ($(shell uname -m),x86_64)
			PLATFORM = x64.release.sample
		endif
		CCFLAGS += -std=c++11
		SHLIB_LINK += -lrt -std=c++11 -lc++
	endif
endif
