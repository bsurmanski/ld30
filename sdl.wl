
use "importc"

import(C) "SDL/SDL.h"

// assumes BBP is 4, since otherwise the int^ will overlap other pxls
int getPixel(SDL_Surface ^s, int x, int y) {
    int ^r = &(s.pixels[x * s.format.BytesPerPixel + y * s.pitch])
    return ^r
}

void setPixel(SDL_Surface^ s, int x, int y, int val) {
    if(x < 0) return
    if(y < 0) return
    if(x >= s.w) return
    if(y >= s.h) return
    int ^r = &(s.pixels[x * s.format.BytesPerPixel + y * s.pitch])
    ^r = val
}
