
use "importc"
import(C) "SDL/SDL.h"
import(C) "SDL/SDL_image.h"

import "map.wl"
import "block.wl"

SDL_Surface^ sprite = null

const int STATE_FALLING = 0
const int STATE_STANDING = 1

class Player {
    float x
    float y
    float vx
    float vy

    int state

    bool top_blocked

    this() {
        .x = 0
        .y = 0
        .vx = 0
        .vy = 0

        .state = 0

        .top_blocked = false

        if(!sprite) {
            sprite = IMG_Load("res/player.png")
        }
    }

    void update(Map map) {
        if(.vy < 8) .vy = .vy + 0.2


        /*
         * Collision Detection below
         */

        // Bottom samples
        Block bl = map.getChunk().getBlock((.x+3) / 16, (.y / 16) + 1)
        Block br = map.getChunk().getBlock((.x+12) / 16, (.y / 16) + 1)
        if(bl.isSolid() || br.isSolid()) {
            if(.vy > 0) {
                .vy = 0
                .y = (int:(.y / 16)) * 16 // round the y value
            }
            .state = STATE_STANDING
        } else {
            .state = STATE_FALLING
        }

        // Top samples
        Block tl = map.getChunk().getBlock((.x+3) / 16, (.y / 16))
        Block tr = map.getChunk().getBlock((.x+12) / 16, (.y / 16))
        if(tl.isSolid() || tr.isSolid()) {
            if(.vy < 0) {
                .vy = 0
                .y = ((int:(.y / 16)) + 1) * 16 // round the y value
            }
        }

        // top is blocked, can not jump
        Block ttl = map.getChunk().getBlock((.x+3) / 16, ((.y-5) / 16))
        Block ttr = map.getChunk().getBlock((.x+12) / 16, ((.y-5) / 16))
        if(ttl.isSolid() || ttr.isSolid()) .top_blocked = true
        else .top_blocked = false

        // Left samples
        Block lt = map.getChunk().getBlock((.x) / 16, (.y+3) / 16)
        Block lb = map.getChunk().getBlock((.x) / 16, (.y+12) / 16)
        if(lt.isSolid() || lb.isSolid()) {
            if(.vx < 0) {
                .vx = 0
                .x = ((int:(.x / 16)) + 1) * 16 // round the x value
            }
        }

        // Right samples
        Block rt = map.getChunk().getBlock((.x) / 16 + 1, (.y+3) / 16)
        Block rb = map.getChunk().getBlock((.x) / 16 + 1, (.y+12) / 16)
        if(rt.isSolid() || rb.isSolid()) {
            if(.vx > 0) {
                .vx = 0
                .x = ((int:(.x / 16))) * 16 // round the x value
            }
        }
        /*
         * Collision Detection Above
         */

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

        if(keystate[SDLK_w] && .state == STATE_STANDING && !.top_blocked) {
            .vy = -5
        }
    }

    void draw(SDL_Surface^ dst) {
        SDL_Rect r = [int:.x, int:.y, 16, 16]
        SDL_UpperBlit(sprite, null, dst, &r)
    }
}
