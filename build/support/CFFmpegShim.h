// Swift-visible shims for FFmpeg C macros that the Clang importer cannot expose.
#ifndef CFFMPEG_SHIM_H
#define CFFMPEG_SHIM_H

#include <errno.h>
#include <aether_ffmpeg/libavutil/avutil.h>
#include <aether_ffmpeg/libavutil/error.h>
#include <aether_ffmpeg/libavutil/rational.h>

static inline int aether_averror(int posix_errno) { return AVERROR(posix_errno); }
static inline int aether_averror_eof(void) { return AVERROR_EOF; }
static inline int aether_averror_eagain(void) { return AVERROR(EAGAIN); }
static inline int aether_averror_exit(void) { return AVERROR_EXIT; }
static inline int aether_averror_invaliddata(void) { return AVERROR_INVALIDDATA; }
static inline int aether_averror_decoder_not_found(void) { return AVERROR_DECODER_NOT_FOUND; }

static inline int aether_is_eagain(int ret) { return ret == AVERROR(EAGAIN); }
static inline int aether_is_eof(int ret) { return ret == AVERROR_EOF; }

static inline int64_t aether_av_nopts_value(void) { return AV_NOPTS_VALUE; }
static inline AVRational aether_av_time_base_q(void) { return AV_TIME_BASE_Q; }

#endif /* CFFMPEG_SHIM_H */
