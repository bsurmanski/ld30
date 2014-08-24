
use "importc"
import(C) "SDL/SDL.h"
import(C) "SDL/SDL_image.h"

SDL_Surface^ sprite = null

struct Player {
    float x
    float y
    float vx
    float vy

    this() {
        .x = 0
        .y = 0
        .vx = 0
        .vy = 0

        if(!sprite) {
            sprite = IMG_Load("res/player.png")
        }
    }

    void update() {
        .vy = .vy + 0.1

        .x += .vx
        .y += .vy
    }

    void input(uint8^ keystate) {
        if(keystate[SDLK_a]){
            .vx = .vx - 0.2
        }

        if(keystate[SDLK_d]) {
            .vx = .vx + 0.2
        }
    }

    void draw(SDL_Surface^ dst) {
        SDL_Rect r = [int:.x, int:.y, 16, 16]
        SDL_UpperBlit(sprite, null, dst, &r)
    }
}
