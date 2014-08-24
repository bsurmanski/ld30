
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
        }
    }

    bool isDeadly() {
        return false
    }

    void draw(SDL_Surface ^dst, int x, int y) {
        SDL_Rect r = [x * 16, y * 16, 16, 16]
        SDL_UpperBlit(blockImages[.id], null, dst, &r)
    }
}
