
use "importc"
import(C) "SDL/SDL.h"
import(C) "SDL/SDL_image.h"
import(C) "stdlib.h"

import "map.wl"
import "block.wl"
import "camera.wl"
import "sdl.wl"

SDL_Surface^ sprite = null
SDL_Surface^ usprite = null
SDL_Surface^ xsprite = null

bool player_init = false

const int STATE_FALLING = 0
const int STATE_STANDING = 1
const int STATE_DEAD = 2
const int MAX_XSPEED = 10
const int MAX_YSPEED = 8
const float Y_ACCEL = 0.2

List list

struct Node {
    Node^ next
    Node^ prev
    Particle value

    this(Node^ prev, Node^ next, Particle p) {
        .next = next
        .prev = prev

        // automatically stitch up Linked list
        if(.next) {
            .next.prev = this
        }
        if(.prev) {
            .prev.next = this
        }

        .value = p
    }

    ~this() {
        // stitch up left and right if deleted
        if(.next) {
            .next.prev = .prev
        }

        if(.prev) {
            .prev.next = .next
        }
    }
}

struct Particle {
    float x
    float y
    float vx
    float vy
    int color

    bool update(Map map) {
        .vy += Y_ACCEL
        .x += .vx
        .y += .vy
        Block bl = map.getBlock(.x, .y)
        if(bl.isSolid()) return true
        return false
    }

    void draw(SDL_Surface ^surf, Camera cam) {
        surf.setPixel(.x - cam.x, .y - cam.y, .color)
    }
}

class List {
    Node ^first

    this() {
        .first = null
    }

    void update(Map map) {
        Node ^node = list.first
        while(node) {
            bool del = node.value.update(map)
            if(del) {
                Node ^next = node.next
                if(node == list.first) list.first = null
                delete node
                node = next
            } else {
                node = node.next
            }
        }
    }

    void draw(SDL_Surface^ surf, Camera cam) {
        Node ^node = list.first
        while(node) {
            node.value.draw(surf, cam)
            node = node.next
        }
    }

    void prepend(Particle particle) {
        Node ^n = new Node(null, .first, particle)
        .first = n
    }
}

float rand_float() {
    return 0.5f - (float: rand()) / (float: RAND_MAX)
}

class Player {
    float x
    float y
    float vx
    float vy

    int state

    bool upside
    bool top_blocked

    this() {
        .x = 0
        .y = 0
        .vx = 0
        .vy = 0

        .state = 0

        .top_blocked = false

        if(!player_init) {
            sprite = IMG_Load("res/player.png")
            usprite = IMG_Load("res/uplayer.png")
            xsprite = IMG_Load("res/xplayer.png")
            list = new List()
        }
    }

    void reset() {
        .x = 0
        .y = 0
        .vx = 0
        .vy = 0

        .state = 0

        .top_blocked = false
    }

    bool rightSide() {
        return .y < 260 // 16th block down
    }

    bool isAlive() return .state != STATE_DEAD

    void update(Map map) {
        if(.vy < MAX_YSPEED && .rightSide()) .vy = .vy + Y_ACCEL
        if(.vy > -MAX_YSPEED && !.rightSide()) .vy = .vy - Y_ACCEL

        // dont allow players to go backward
        if(.x < -20) .state = STATE_DEAD

        // passing downward through boundary
        if(.upside && !.rightSide()) {
            for(int i = 0; i < 10; i++) {
                Particle p = [.x, .y, rand_float() * 3.0, rand_float() - .vy, 0x0000ffff]
                //list.prepend(p) //XXX add particle to list
            }
        }
        .upside = .rightSide()

        //list.update(map) // XXX update particles

        /*
         * Collision Detection below
         */

        // Bottom samples
        Block bl = map.getBlock(.x + 3, .y + 16)
        Block br = map.getBlock(.x + 12, .y + 16)
        if(bl.isSolid() || br.isSolid()) {
            if(.vy > 0) {
                .vy = 0
                .y = (int:(.y / 16)) * 16 // round the y value
            }
            if(.rightSide() && .isAlive()) .state = STATE_STANDING
        } else if(.rightSide() && .isAlive()) .state = STATE_FALLING

        // Top samples
        Block tl = map.getBlock(.x+3, .y)
        Block tr = map.getBlock(.x+12, .y)
        if(tl.isSolid() || tr.isSolid()) {
            if(.vy < 0) {
                .vy = 0
                .y = ((int:(.y / 16)) + 1) * 16 // round the y value
            }
            if(!.rightSide() && .isAlive()) .state = STATE_STANDING
        } else if(!.rightSide() && .isAlive()) .state = STATE_FALLING

        if(.rightSide()) {
            // top is blocked, can not jump
            Block ttl = map.getBlock(.x+3, .y-5)
            Block ttr = map.getBlock(.x+12, .y-5)
            if(ttl.isSolid() || ttr.isSolid()) .top_blocked = true
            else .top_blocked = false
        } else {
            // bottom is blocked, can not jump (upside down)
            Block bbl = map.getBlock(.x+3, .y+20)
            Block bbr = map.getBlock(.x+12, .y+20)
            if(bbl.isSolid() || bbr.isSolid()) .top_blocked = true
            else .top_blocked = false
        }

        // Left samples
        Block lt = map.getBlock(.x, .y+3)
        Block lb = map.getBlock(.x, .y+12)
        if(lt.isSolid() || lb.isSolid()) {
            if(.vx < 0) {
                .vx = 0
                .x = ((int:(.x / 16)) + 1) * 16 // round the x value
            }
        }

        // Right samples
        Block rt = map.getBlock(.x + 16, .y+3)
        Block rb = map.getBlock(.x + 16, .y+12)
        if(rt.isSolid() || rb.isSolid()) {
            if(.vx > 0) {
                .vx = 0
                .x = ((int:(.x / 16))) * 16 // round the x value
            }
        }

        if(bl.isDeadly() or br.isDeadly() or tl.isDeadly() or tr.isDeadly() or
            lt.isDeadly() or lb.isDeadly() or rt.isDeadly() or rb.isDeadly()) {
            .state = STATE_DEAD
        }

        /*
         * Collision Detection Above
         */

        .x += .vx
        .y += .vy
    }

    void input(uint8^ keystate) {
        if(.state == STATE_DEAD) return
        if(keystate[SDLK_a] && .vx > -MAX_XSPEED){
            .vx = .vx - 0.2
        }

        if(keystate[SDLK_d] && .vx < MAX_XSPEED) {
            .vx = .vx + 0.2
        }

        if(!.isAlive() || (keystate[SDLK_d] && keystate[SDLK_a])) {
            .vx = .vx * 0.95
        }

        if(keystate[SDLK_w] && .state == STATE_STANDING && !.top_blocked && .rightSide()) {
            .vy = -5
        }

        if(keystate[SDLK_s] && .state == STATE_STANDING && !.top_blocked && !.rightSide()) {
            .vy = 5
        }
    }

    void draw(SDL_Surface^ dst, Camera cam) {
        SDL_Rect r = [int: (.x - cam.x), int:(.y - cam.y), 16, 16]
        if(!.isAlive()) SDL_UpperBlit(xsprite, null, dst, &r)
        else if(.rightSide()) SDL_UpperBlit(sprite, null, dst, &r)
        else SDL_UpperBlit(usprite, null, dst, &r)
        // list.draw(dst, cam) // XXX draw particles
    }
}
