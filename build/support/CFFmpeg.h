// Umbrella header for the CFFmpeg module (AetherEngine binary distribution).
#ifndef CFFMPEG_UMBRELLA_H
#define CFFMPEG_UMBRELLA_H

#include <aether_ffmpeg/libavformat/avformat.h>
#include <aether_ffmpeg/libavformat/avio.h>
#include <aether_ffmpeg/libavformat/version.h>

#include <aether_ffmpeg/libavcodec/avcodec.h>
#include <aether_ffmpeg/libavcodec/codec.h>
#include <aether_ffmpeg/libavcodec/codec_desc.h>
#include <aether_ffmpeg/libavcodec/bsf.h>
#include <aether_ffmpeg/libavcodec/videotoolbox.h>
#include <aether_ffmpeg/libavcodec/version.h>

#include <aether_ffmpeg/libavutil/avutil.h>
#include <aether_ffmpeg/libavutil/opt.h>
#include <aether_ffmpeg/libavutil/dict.h>
#include <aether_ffmpeg/libavutil/error.h>
#include <aether_ffmpeg/libavutil/frame.h>
#include <aether_ffmpeg/libavutil/imgutils.h>
#include <aether_ffmpeg/libavutil/samplefmt.h>
#include <aether_ffmpeg/libavutil/channel_layout.h>
#include <aether_ffmpeg/libavutil/pixdesc.h>
#include <aether_ffmpeg/libavutil/pixfmt.h>
#include <aether_ffmpeg/libavutil/time.h>
#include <aether_ffmpeg/libavutil/mathematics.h>
#include <aether_ffmpeg/libavutil/rational.h>
#include <aether_ffmpeg/libavutil/display.h>
#include <aether_ffmpeg/libavutil/log.h>
#include <aether_ffmpeg/libavutil/hwcontext.h>
#include <aether_ffmpeg/libavutil/hwcontext_videotoolbox.h>
#include <aether_ffmpeg/libavutil/mastering_display_metadata.h>
#include <aether_ffmpeg/libavutil/hdr_dynamic_metadata.h>
#include <aether_ffmpeg/libavutil/dovi_meta.h>
#include <aether_ffmpeg/libavutil/stereo3d.h>
#include <aether_ffmpeg/libavutil/version.h>

#include <aether_ffmpeg/libswresample/swresample.h>
#include <aether_ffmpeg/libswscale/swscale.h>

#include <aether_ffmpeg/libavfilter/avfilter.h>
#include <aether_ffmpeg/libavfilter/buffersrc.h>
#include <aether_ffmpeg/libavfilter/buffersink.h>

#include "CFFmpegShim.h"

#endif /* CFFMPEG_UMBRELLA_H */
