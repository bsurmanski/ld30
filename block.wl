
use "importc"
import(C) "SDL/SDL.h"
import(C) "SDL/SDL_image.h"

SDL_Surface^[] blockImages

int BLOCK_EMPTY = 0
int BLOCK_ROCK = 1

void block_init() {
    blockImages = new SDL_Surface^[50]
    for(int i = 0; i < 2; i++) {
        char[20] str
        sprintf(str.ptr, "res/blocks/%d.png", i)
        blockImages[i] = IMG_Load(str.ptr)
    }
}

struct Block {
    int id;

    this(int pxl) {
        switch(pxl) {
            case 0xffffffff
                .id = BLOCK_EMPTY
            case 0x0
                .id = BLOCK_ROCK
        }
    }

    bool isDeadly() {
        return false
    }
}
