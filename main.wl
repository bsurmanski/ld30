use "importc"

import(C) "SDL/SDL.h"
import(C) "SDL/SDL_image.h"
import(C) "math.h"

import "map.wl"
import "player.wl"
import "camera.wl"
import "killwall.wl"

bool running = true
SDL_Surface^ surf
Map map
Player player
Camera camera

SDL_Surface^[] font

void init() {
    surf = SDL_SetVideoMode(640, 480, 32, SDL_SWSURFACE)
    IMG_Init(IMG_INIT_PNG)
    map = new Map()
    player = new Player()
    camera = new Camera()

    font = new SDL_Surface^[10]

    for(int i = 0; i < 10; i++) {
        char[32] path
        sprintf(path.ptr, "res/font/%d.png", i)
        font[i] = IMG_Load(path.ptr)
    }

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

int oldTime = 0
int newTime = 0
void delay() {
    oldTime = newTime
    newTime = SDL_GetTicks()
    printf("%d\n", newTime - oldTime);
    if(newTime - oldTime < 16) {
        SDL_Delay(newTime - oldTime)
    }
}

void title() {
    player.reset()
    map.reset()
    SDL_Surface ^img = IMG_Load("res/title.png")
    while(running) {
        SDL_PumpEvents()
        uint8^ keystate = SDL_GetKeyState(null)
        if(keystate[SDLK_SPACE]) break
        if(keystate[SDLK_ESCAPE]) running = false
        SDL_UpperBlit(img, null, surf, null)
        SDL_Flip(surf)
        delay()
    }
    SDL_FreeSurface(img)
}

void drawScore() {
    int score = player.blocksPassed
    if(score < 0) score = 0

    uint ndig = floor(log10(score)) + 1
    uint dign = 1
    while(score) {
        uint sdig = score % 10
        score = score / 10

        SDL_Rect r = [300 + (ndig-dign) * 32, 220, 32, 64]
        SDL_UpperBlit(font[sdig], null, surf, &r)

        dign++
    }
}

void score() {
    SDL_Surface ^img = IMG_Load("res/score.png")
    while(running) {
        SDL_PumpEvents()
        uint8^ keystate = SDL_GetKeyState(null)
        if(keystate[SDLK_SPACE]) break
        if(keystate[SDLK_ESCAPE]) running = false
        SDL_UpperBlit(img, null, surf, null)
        drawScore()
        SDL_Flip(surf)
        delay()
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
        score()
    }
    deinit()
}

int main(int argc, char^^ argv) {
    run()
    return 0
}
