use "importc"

import(C) "SDL/SDL.h"
import(C) "SDL/SDL_image.h"

import "map.wl"

bool running = true
SDL_Surface^ surf;
Map ^map;

void init() {
    surf = SDL_SetVideoMode(640, 480, 32, SDL_SWSURFACE)
    IMG_Init(IMG_INIT_PNG)
    map = new Map()
}

void deinit() {
    IMG_Quit()
    SDL_Quit()
}

void input() {
    SDL_PumpEvents()
    uint8^ keystate = SDL_GetKeyState(null)
    if(keystate[SDLK_SPACE]) {
        running = false
    }
}

void draw() {
    map.draw(surf)
}

void update() {
}

void delay() {
    SDL_Delay(16)
}

void run() {
    init()
    while(running) {
        input()
        update()
        draw()
        delay()
    }
    deinit()
}

int main(int argc, char^^ argv) {
    run()
    return 0
}
