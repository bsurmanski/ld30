
use "importc"
import(C) "SDL/SDL.h"
import(C) "SDL/SDL_image.h"

import "camera.wl"

SDL_Surface^[] blockImages

const int BLOCK_EMPTY = 0
const int BLOCK_ROCK = 1
const int BLOCK_SPIKE = 2

void block_init() {
    blockImages = new SDL_Surface^[50]
    for(int i = 0; i < 3; i++) {
        char[20] str
        sprintf(str.ptr, "res/blocks/%d.png", i)
        blockImages[i] = IMG_Load(str.ptr)

        if(blockImages[i]) {
            printf("block %d loaded\n", i)
        }
    }
}

struct Block {
    int id;

    this(int pxl) {
        .id = BLOCK_EMPTY
        switch(pxl) {
            printf("weird pxl: %x\n", pxl)
            case 0xffffffff
                .id = BLOCK_EMPTY
            case 0x0, 0xff000000
                .id = BLOCK_ROCK
            case 0xff0000ff
                .id = BLOCK_SPIKE
        }
    }

    bool isSolid() {
        switch(.id) {
            case BLOCK_ROCK
            return true
        }
        return false;
    }

    bool isDeadly() {
        return .id == BLOCK_SPIKE
    }

    void draw(SDL_Surface ^dst, int x, int y, Camera cam) {
        SDL_Rect r = [int: (x * 16 - cam.x), int: (y * 16 - cam.y), 16, 16]
        SDL_UpperBlit(blockImages[.id], null, dst, &r)
    }

    void drawOffset(SDL_Surface^ dst, float x, float y, Camera cam) {
        SDL_Rect r = [int: (x - cam.x), int: (y - cam.y), 16, 16]
        SDL_UpperBlit(blockImages[.id], null, dst, &r)
    }
}
