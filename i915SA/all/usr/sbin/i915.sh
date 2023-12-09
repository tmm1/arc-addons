#!/bin/sh

insmod i2c-algo-bit.ko
insmod backport-sa6400-export.ko
insmod backport-dma-buf.ko
insmod hdmi.ko
insmod backlight.ko
insmod drm_panel_orientation_quirks.ko
insmod drm.ko
insmod fbdev.ko
insmod fbcore.ko
insmod drm_kms_helper.ko
insmod backport-sa6400.ko
insmod drm_mipi_dsi.ko
insmod video.ko
insmod i915.ko enable_guc=2