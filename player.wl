
use "importc"
import(C) "SDL/SDL.h"
import(C) "SDL/SDL_image.h"

import "map.wl"
import "block.wl"
import "camera.wl"

SDL_Surface^ sprite = null
SDL_Surface^ usprite = null

bool player_init = false

const int STATE_FALLING = 0
const int STATE_STANDING = 1
const int MAX_XSPEED = 10
const int MAX_YSPEED = 8
const float Y_ACCEL = 0.2

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

        if(!player_init) {
            sprite = IMG_Load("res/player.png")
            usprite = IMG_Load("res/uplayer.png")
        }
    }

    bool rightSide() {
        return .y < 260 // 16th block down
    }

    void update(Map map) {
        if(.vy < MAX_YSPEED && .rightSide()) .vy = .vy + Y_ACCEL
        if(.vy > -MAX_YSPEED && !.rightSide()) .vy = .vy - Y_ACCEL

        /*
         * Collision Detection below
         */

        // Bottom samples
        Block bl = map.getBlock(.x + 3, .y + 16)
        Block br = map.getBlock(.x + 12, .y + 16)
        if(bl.isSolid() || br.isSolid()) {
            if(.vy > 0) {
                .vy = 0
                .y = (int:(.y / 16)) * 16 // round the y value
            }
            if(.rightSide()) .state = STATE_STANDING
        } else if(.rightSide()) .state = STATE_FALLING

        // Top samples
        Block tl = map.getBlock(.x+3, .y)
        Block tr = map.getBlock(.x+12, .y)
        if(tl.isSolid() || tr.isSolid()) {
            if(.vy < 0) {
                .vy = 0
                .y = ((int:(.y / 16)) + 1) * 16 // round the y value
            }
            if(!.rightSide()) .state = STATE_STANDING
        } else if(!.rightSide()) .state = STATE_FALLING

        if(.rightSide()) {
            // top is blocked, can not jump
            Block ttl = map.getBlock(.x+3, .y-5)
            Block ttr = map.getBlock(.x+12, .y-5)
            if(ttl.isSolid() || ttr.isSolid()) .top_blocked = true
            else .top_blocked = false
        } else {
            // bottom is blocked, can not jump (upside down)
            Block bbl = map.getBlock(.x+3, .y+20)
            Block bbr = map.getBlock(.x+12, .y+20)
            if(bbl.isSolid() || bbr.isSolid()) .top_blocked = true
            else .top_blocked = false
        }

        // Left samples
        Block lt = map.getBlock(.x, .y+3)
        Block lb = map.getBlock(.x, .y+12)
        if(lt.isSolid() || lb.isSolid()) {
            if(.vx < 0) {
                .vx = 0
                .x = ((int:(.x / 16)) + 1) * 16 // round the x value
            }
        }

        // Right samples
        Block rt = map.getBlock(.x + 16, .y+3)
        Block rb = map.getBlock(.x + 16, .y+12)
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
        if(keystate[SDLK_a] && .vx > -MAX_XSPEED){
            .vx = .vx - 0.2
        }

        if(keystate[SDLK_d] && .vx < MAX_XSPEED) {
            .vx = .vx + 0.2
        }

        if(keystate[SDLK_w] && .state == STATE_STANDING && !.top_blocked && .rightSide()) {
            .vy = -5
        }

        if(keystate[SDLK_s] && .state == STATE_STANDING && !.top_blocked && !.rightSide()) {
            .vy = 5
        }
    }

    void draw(SDL_Surface^ dst, Camera cam) {
        SDL_Rect r = [int: (.x - cam.x), int:(.y - cam.y), 16, 16]
        if(.rightSide()) SDL_UpperBlit(sprite, null, dst, &r)
        else SDL_UpperBlit(usprite, null, dst, &r)
    }
}
