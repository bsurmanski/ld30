use "importc"

import(C) "SDL/SDL.h"
import(C) "SDL/SDL_image.h"

import "block.wl"
import "chunk.wl"

bool map_init = false;

struct Map {
    Chunk ^c;

    this() {
        printf("loading map\n")
        if(!map_init) {
            block_init()
            map_init = true
        }
        .c = new Chunk("res/chunks/0.png");
    }

    void draw(SDL_Surface^ dst) {
        .c.draw(dst)
    }

    Chunk ^getChunk() {
        return .c
    }
}
