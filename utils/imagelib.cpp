#include "imagelib.h"

ImageLib::ImageLib() {

}

/* 0: nearest
 * 1: bilinear
 */

QImage* ImageLib::scale(const QImage *source, QSize destSize, int method) {
    switch (method) {
        case 0:
            return scale_Qt(source, destSize, false);
        case 1:
            return scale_Qt(source, destSize, true);
        /*case 2:
            return scale_FreeImage(source, destSize, FILTER_BICUBIC);
        case 3:
            return scale_FreeImage(source, destSize, FILTER_CATMULLROM);
        case 4:
            return scale_FreeImage(source, destSize, FILTER_LANCZOS3);
            */
        default:
            return scale_Qt(source, destSize, true);
    }
}

QImage* ImageLib::scale_Qt(const QImage *source, QSize destSize, bool smooth) {
    QImage *dest = new QImage();
    Qt::TransformationMode mode = smooth ? Qt::SmoothTransformation : Qt::FastTransformation;
    *dest = source->scaled(destSize.width(), destSize.height(), Qt::IgnoreAspectRatio, mode);
    return dest;
}

/*
QImage* ImageLib::scale_FreeImage(const QImage *source, QSize destSize, FREE_IMAGE_FILTER filter) {
    FIBITMAP *fiOrig = FreeImage_ConvertFromRawBitsEx(false, (BYTE*)source->bits(),
                                                      FIT_BITMAP,
                                                      source->width(),
                                                      source->height(),
                                                      source->bytesPerLine(),
                                                      source->depth(),
                                                      FI_RGBA_RED_MASK,
                                                      FI_RGBA_GREEN_MASK,
                                                      FI_RGBA_BLUE_MASK);
    QImage *dest = new QImage(destSize, source->format());
    FIBITMAP *fiScaled = FreeImage_Rescale(fiOrig, dest->width(), dest->height(), filter);
    FreeImage_Unload(fiOrig);
    int pitch = FreeImage_GetPitch(fiScaled);
    int height = FreeImage_GetHeight(fiScaled);
    memcpy( dest->bits(), FreeImage_GetBits(fiScaled), pitch * height );
    FreeImage_Unload(fiScaled);
    return dest;
}
*/
