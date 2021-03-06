module game;
import bsp;
import io;

const int max_body_len = 50;
const int grid_size = 20;
const int UP = 0, LEFT = 1, DOWN = 2, RIGHT = 3;

type struct {
    struct
    {
        int x;
        int y;
    }[max_body_len] elements;
    int head;
    int tail;
    int length;
    int new_length;
    int direction;
} body_t;

type int[grid_size][grid_size] map_t;

type struct {
    int decimator;
} game_t;

// Global variables with state info:
var body_t body;
var map_t map;
var map_t render;
var game_t game;

public function void init()
{
    var int i;
    for (i = 0; i < grid_size; i += 1)
    {
        map[i][0] = 1;
        map[i][grid_size-1] = 1;
        map[0][i] = 1;
        map[grid_size-1][i] = 1;
    }

    body.head = 0;
    body.tail = 0;
    body.length = 0;
    body.new_length = 10;
    body.elements[body.head].x = grid_size >> 1;
    body.elements[body.head].y = grid_size >> 1;
    game.decimator = 0;
}

function void increment_ptr(int* ptr)
{
    (*ptr) += 1;
    if (*ptr >= max_body_len)
    {
        *ptr = 0;
    }
}

// Advance the snake one step
function void step_snake()
{
    var int x, y, dx, dy;

    x = body.elements[body.head].x;
    y = body.elements[body.head].y;

    if (body.direction == UP and y > 0)
    {
        y -= 1;
    }

    if (body.direction == LEFT and x > 0)
    {
        x -= 1;
    }

    if (body.direction == DOWN and y < grid_size - 1)
    {
        y += 1;
    }

    if (body.direction == RIGHT and x < grid_size - 1)
    {
        x += 1;
    }

    body.length += 1;
    increment_ptr(&body.head);
    while (body.length > body.new_length)
    {
        body.length -= 1;
        increment_ptr(&body.tail);
    }

    body.elements[body.head].x = x;
    body.elements[body.head].y = y;
}

// Copy map and snake to display
function void make_output()
{
    var int x, y, i;

    y = 0;
    x = 0;

    // Blit map to render:
    for (x = 0; x < grid_size; x += 1)
    {
        for (y = 0; y < grid_size; y += 1)
        {
            if (map[x][y] == 0)
            {
                render[x][y] = 32;
            }
            else
            {
                render[x][y] = 65;
            }
        }
    }

    // TODO:
    // Render snake to render:
    for (i = body.tail; i != body.head; increment_ptr(&i))
    {
        x = body.elements[i].x;
        y = body.elements[i].y;
        render[x][y] = 67;
    }

    // The head:
    x = body.elements[body.head].x;
    y = body.elements[body.head].y;
    render[x][y] = 66;
}

function void print_render()
{
    var int x, y;

    x = 0;
    y = 0;

    // Move to home:
    bsp.putc(27); // escape character
    io.print("[H"); // vt100 move to home

    // Set color:
    bsp.putc(27);
    io.print("[2;32m");

    io.print("Welcome to snake!");
    io.print("Key:");
    io.print_int(key_press);
    bsp.putc(10);

    // Blit map to render:
    for (y = 0; y < grid_size; y += 1)
    {
        for (x = 0; x < grid_size; x += 1)
        {
            // Put character two times for aspect ratio:
            bsp.putc(render[x][y]);
            bsp.putc(render[x][y]);
        }

        bsp.putc(10);
    }

    // Reset attribute:
    bsp.putc(27);
    io.print("[0m");
}

var int key_press;
// Perform all actions for a tick in the game
public function void single_step()
{
    // Handle input:
    if (bsp.get_key(&key_press))
    {
        // asd-w navigation:
        if (key_press == 65 or key_press == 97)
        {
            body.direction = LEFT;
        }

        if (key_press == 87 or key_press == 119)
        {
            body.direction = UP;
        }

        if (key_press == 83 or key_press == 115)
        {
            body.direction = DOWN;
        }

        if (key_press == 68 or key_press == 100)
        {
            body.direction = RIGHT;
        }
    }

    // Step snake:
    if (game.decimator > 0)
    {
        game.decimator -= 1;
    }
    else
    {
        game.decimator = 3;
        step_snake();
    }
    make_output();
    print_render();
}

