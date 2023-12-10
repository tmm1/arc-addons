#!/bin/sh

insmod /usr/lib/modules/i2c-algo-bit.ko
insmod /usr/lib/modules/backport-sa6400-export.ko
insmod /usr/lib/modules/backport-dma-buf.ko
insmod /usr/lib/modules/hdmi.ko
insmod /usr/lib/modules/backlight.ko
insmod /usr/lib/modules/drm_panel_orientation_quirks.ko
insmod /usr/lib/modules/drm.ko
insmod /usr/lib/modules/fbdev.ko
insmod /usr/lib/modules/fbcore.ko
insmod /usr/lib/modules/drm_kms_helper.ko
insmod /usr/lib/modules/backport-sa6400.ko
insmod /usr/lib/modules/drm_mipi_dsi.ko
insmod /usr/lib/modules/video.ko
insmod /usr/lib/modules/i915.ko enable_guc=2