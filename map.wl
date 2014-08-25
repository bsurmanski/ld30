use "importc"

import(C) "SDL/SDL.h"
import(C) "SDL/SDL_image.h"

import "block.wl"
import "chunk.wl"

bool map_init = false

Chunk^[] chunks

class Map {
    this() {
        printf("loading map\n")
        if(!map_init) {
            block_init()
            chunks = new Chunk^[50]

            for(int i = 0; i < 50; i++) {
                char[128] str
                sprintf(str, "res/chunks/%d.png", i)
                SDL_Surface^ surf = IMG_Load(str.ptr)
                if(surf) chunks[i] = new Chunk(surf)
                else chunks[i] = null
            }

            map_init = true
        }
    }

    void draw(SDL_Surface^ dst) {
        chunks[0].draw(dst)
    }

    Chunk ^getChunk() {
        return chunks[0]
    }
}
