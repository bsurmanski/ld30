use "importc"

import(C) "SDL/SDL.h"
import(C) "SDL/SDL_image.h"

import "block.wl"
import "chunk.wl"
import "camera.wl"

bool map_init = false

Chunk^[] chunks
SDL_Surface^ background

class Map {
    this() {
        printf("loading map\n")
        if(!map_init) {
            block_init()
            chunks = new Chunk^[50]
            background = IMG_Load("res/background.png")

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

    void draw(SDL_Surface^ dst, Camera cam) {
        SDL_Rect r = [(-cam.x) % 1024, (-cam.y) % 1024, 512, 512]
        SDL_UpperBlit(background, null, dst, &r)

        SDL_Rect r2 = [(512-cam.x) % 1024, (-cam.y) % 1024, 512, 512]
        SDL_UpperBlit(background, null, dst, &r2)

        SDL_Rect r3 = [(-(cam.x+512)) % 1024, (-cam.y) % 1024, 512, 512]
        SDL_UpperBlit(background, null, dst, &r3)

        chunks[0].draw(dst, cam, 0)
        chunks[0].draw(dst, cam, 64)
    }

    Block getBlock(long x, long y) {
        return .getChunk().getBlock(x / 16, y / 16)
    }

    Chunk ^getChunk() {
        return chunks[0]
    }
}
