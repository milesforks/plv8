#-----------------------------------------------------------------------------#
#
# Makefile for v8 static link
#
# 'make' will download the v8 source and build it, then build plv8
# with statically link to v8 with snapshot.  This assumes certain directory
# structure in v8 which may be different from version to another, but user
# can specify the v8 version by AUTOV8_VERSION, too.
#-----------------------------------------------------------------------------#
NODEJS_VERSION = v12.3.0
NODEJS_DIR = build/node
AUTOV8_DIR = $(NODEJS_DIR)/deps/v8
AUTOV8_OUT = $(NODEJS_DIR)/out/Release
AUTOV8_LIB = $(AUTOV8_OUT)/libv8_snapshot.a
AUTOV8_STATIC_LIBS = -lv8_base -lv8_snapshot -lv8_libplatform -lv8_libbase -lv8_libsampler -lgenerate_snapshot

SHLIB_LINK += -L$(abspath $(AUTOV8_OUT)) $(AUTOV8_STATIC_LIBS)
V8_OPTIONS = is_component_build=false v8_static_library=true v8_use_snapshot=true v8_use_external_startup_data=false use_custom_libcxx=false

ifndef USE_ICU
	NODEJS_OPTIONS += --without-intl
endif

all: v8

# For some reason, this solves parallel make dependency.
plv8_config.h plv8.so: v8

$(NODEJS_DIR):
	mkdir -p build
	cd build; git clone https://github.com/nodejs/node.git

$(NODEJS_DIR)/config.status: $(NODEJS_DIR)
	cd build; cd node; git checkout $(NODEJS_VERSION); ./configure $(NODEJS_OPTIONS); cd ..

v8: $(NODEJS_DIR)/config.status
	env CXXFLAGS=-fPIC CFLAGS=-fPI make -C $(NODEJS_DIR) v8

include Makefile.shared

ifdef EXECUTION_TIMEOUT
	CCFLAGS += -DEXECUTION_TIMEOUT
endif

ifdef JSONB_DIRECT_CONVERSION
	CCFLAGS += -DJSONB_DIRECT_CONVERSION
endif

# enable direct jsonb conversion by default
CCFLAGS += -DJSONB_DIRECT_CONVERSION

CCFLAGS += -I$(abspath $(AUTOV8_DIR)/include) -I$(abspath $(AUTOV8_DIR))
# We're gonna build static link.  Rip it out after include Makefile
SHLIB_LINK := $(filter-out -lv8, $(SHLIB_LINK))

ifeq ($(OS),Windows_NT)
	# noop for now
else
	SHLIB_LINK += -L$(abspath $(AUTOV8_OUT))
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Darwin)
		CCFLAGS += -stdlib=libc++ -std=c++11
		SHLIB_LINK += -stdlib=libc++
		PLATFORM = x64.release
	endif
	ifeq ($(UNAME_S),Linux)
		ifeq ($(shell uname -m | grep -o arm),arm)
			PLATFORM = arm64.release
		endif
		ifeq ($(shell uname -m),x86_64)
			PLATFORM = x64.release
		endif
		CCFLAGS += -std=c++11
		SHLIB_LINK += -lrt -std=c++11 -lc++
	endif

	DESTCPU = $(firstword $(subst ., ,$(PLATFORM)))
	NODEJS_OPTIONS += --dest-cpu=$(DESTCPU)

	X = $(lastword $(subst ., ,$(PLATFORM)))
	ifneq ($(X),release)
		NODEJS_OPTIONS += --debug
	endif
endif
