use "importc"

import(C) "SDL/SDL.h"
import(C) "SDL/SDL_image.h"
import(C) "math.h"

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

        // draw the background. we draw it 4 times so that
        // it tiles across the screen without any edge.
        // kinda messy, could probably do the same with 2 images, but whatever
        // hard coded '512' is the tiling, 256 is the YOffset to make image fit in center
        SDL_Rect r = [-cam.x % 512, -256-cam.y, 512, 1024]
        SDL_UpperBlit(background, null, dst, &r)

        SDL_Rect r2 = [512-cam.x % 512, -256-cam.y, 512, 1024]
        SDL_UpperBlit(background, null, dst, &r2)

        SDL_Rect r3 = [1024-cam.x % 512, -256-cam.y, 512, 1024]
        SDL_UpperBlit(background, null, dst, &r3)

        SDL_Rect r4 = [-512-cam.x % 512, -256-cam.y, 512, 1024]
        SDL_UpperBlit(background, null, dst, &r4)

        int bx = -cam.x / 16
        .getChunk(bx).draw(dst, cam, floor((0 - bx)/64) * 64)
        .getChunk(bx).draw(dst, cam, floor((64- bx)/64) * 64)
    }

    Block getBlock(long x, long y) {
        int bx = x / 16
        int by = y / 16
        if(x > 0 && y > 0) return .getChunk(bx).getBlock(bx % 64, by % 64)
        return Block(0xffffffff)
    }

    Chunk ^getChunk(int x) {
        return chunks[x % 1]
    }
}
