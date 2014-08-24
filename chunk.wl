
use "importc"
import(C) "SDL/SDL.h"
import(C) "SDL/SDL_image.h"

/*
 * Map chunk
 */

import "block.wl"
import "sdl.wl"

struct Chunk {
    int w
    int h
    Block[] blocks
    SDL_Surface^ s
    this(char^ file) {
        SDL_Surface^ surf = IMG_Load(file)
        .s = surf
        printf("loading chunk '%s'\n", file)
        if(!surf) {
            printf("ERROR!!\n")
        }
        .w = surf.w
        .h = surf.h
        .blocks.ptr = malloc(.w * .h * Block.sizeof) // work around for new Block[w*h] not working
        .blocks.size = .w * .h
        for(int j = 0; j < .h; j++) {
            for(int i = 0; i < .w; i++) {
                int val = surf.getPixel(i, j)
                .blocks[i + j * .w] = Block(val)
            }
        }
    }

    ~this() {
        //delete .blocks
    }

    void draw(SDL_Surface^ dst) {
        //SDL_UpperBlit(.s, null, dst, null)
        for(int j = 0; j < .h; j++) {
            for(int i = 0; i < .w; i++) {
                .blocks[i + j * .w].draw(dst, i, j)
            }
        }
    }
}
