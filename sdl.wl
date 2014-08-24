
use "importc"

import(C) "SDL/SDL.h"

int getPixel(SDL_Surface ^s, int x, int y) {
    int ^r = &(s.pixels[x * s.format.BytesPerPixel + y * s.pitch])
    return ^r
}

void setPixel(SDL_Surface^ s, int x, int y, int val) {
    int ^r = &(s.pixels[x * s.format.BytesPerPixel + y * s.pitch])
    ^r = val
}
