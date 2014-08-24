use "importc"

import(C) "SDL/SDL.h"
import(C) "SDL/SDL_image.h"

import "map.wl"
import "player.wl"

bool running = true
SDL_Surface^ surf
Map ^map
Player ^player

void init() {
    surf = SDL_SetVideoMode(640, 480, 32, SDL_SWSURFACE)
    IMG_Init(IMG_INIT_PNG)
    map = new Map()
    player = new Player()
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

    player.input(keystate)
}

void draw() {
    map.draw(surf)
    player.draw(surf)
    SDL_Flip(surf)
    SDL_FillRect(surf, null, 0x0)
}

void update() {
    player.update(map)
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
