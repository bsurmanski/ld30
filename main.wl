use "importc"

import(C) "SDL/SDL.h"
import(C) "SDL/SDL_image.h"

import "map.wl"
import "player.wl"
import "camera.wl"

bool running = true
SDL_Surface^ surf
Map map
Player player
Camera camera

void init() {
    surf = SDL_SetVideoMode(640, 480, 32, SDL_SWSURFACE)
    IMG_Init(IMG_INIT_PNG)
    map = new Map()
    player = new Player()
    camera = new Camera()

    // something wrong with ref counting :(
    retain camera
    retain player
    retain map
}

void deinit() {
    IMG_Quit()
    SDL_Quit()
}

void input() {
    SDL_PumpEvents()
    uint8^ keystate = SDL_GetKeyState(null)
    if(keystate[SDLK_ESCAPE]) {
        running = false
    }

    player.input(keystate)
}

void draw() {
    map.draw(surf, camera)
    player.draw(surf, camera)
    map.drawOverlay(surf, camera)
    SDL_Flip(surf)
    SDL_FillRect(surf, null, 0xffffffff)
}

void update() {
    camera.setFocus(player.x, player.y)
    camera.update(map)
    player.update(map)
}

void delay() {
    SDL_Delay(16)
}

void title() {
    player.reset()
    SDL_Surface ^img = IMG_Load("res/title.png")
    while(running) {
        SDL_PumpEvents()
        uint8^ keystate = SDL_GetKeyState(null)
        if(keystate[SDLK_SPACE]) break
        if(keystate[SDLK_ESCAPE]) running = false
        SDL_UpperBlit(img, null, surf, null)
        SDL_Flip(surf)
        SDL_Delay(16)
    }
    SDL_FreeSurface(img)
}

void run() {
    init()
    while(running) {
        title()
        int deathTimeout = 200
        while(deathTimeout > 0 && running) {
            input()
            update()
            draw()
            delay()
            if(!player.isAlive()) deathTimeout--
        }
    }
    deinit()
}

int main(int argc, char^^ argv) {
    run()
    return 0
}
