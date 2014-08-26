use "importc"
import(C) "SDL/SDL.h"

import "camera.wl"
import "block.wl"

struct Killwall {
    int timeout
    float x
    float vx

    this() {
        .timeout = 200
        .x = -128
        .vx = 0.1
    }

    void draw(SDL_Surface^ dst, Camera cam) {
        if(.timeout == 0) {
            if(cam.x - .x > -80) {
                .vx = .vx + 0.1 * (1 + ((cam.x - .x) / 100))
            } else {
                .vx = .vx - 0.1
            }
            .timeout = 100
            if(.vx > 2) .vx = 2
            if(.vx < 0) .vx = 0.1
        }

        if(cam.x - .x > 0) .x = .x + 1.5

        .timeout--
        .x = .x + .vx
        Block bl = Block(0xff0000ff)
        for(int i = -32; i < 64; i++) {
            bl.drawOffset(dst, .x, i*16, cam)
        }
    }
}
