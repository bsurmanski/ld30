use "importc"

import(C) "SDL/SDL.h"

SDL_Surface^ surf;
int main(int argc, char^^ argv) {
    surf = SDL_SetVideoMode(640, 480, 32, SDL_SWSURFACE);
    //SDL_Delay(2000);
}
