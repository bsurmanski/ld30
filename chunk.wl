
use "importc"
import(C) "SDL/SDL.h"
import(C) "SDL/SDL_image.h"

/*
 * Map chunk
 */

import "block.wl"
import "camera.wl"
import "sdl.wl"

struct Chunk {
    int w
    int h
    Block[] blocks
    SDL_Surface^ s
    this(SDL_Surface^ surf) {
        .s = surf
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

    void draw(SDL_Surface^ dst, Camera cam, int x) {
        //SDL_UpperBlit(.s, null, dst, null)
        for(int j = 0; j < .h; j++) {
            for(int i = 0; i < .w; i++) {
                Block bl = .getBlock(i, j)
                bl.draw(dst, i + x, j, cam)
            }
        }
    }

    Block getBlock(int i, int j) {
        if(i < .w && j < .h) {
            return .blocks[i + j * .w]
        }
        return Block(0);
    }
}
