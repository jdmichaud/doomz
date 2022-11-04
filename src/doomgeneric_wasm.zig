

// #include "doomkeys.h"
// #include "m_argv.h"
// #include "doomgeneric.h"

// #include <stdio.h>
// #include <unistd.h>

// #include <stdbool.h>
// #include <SDL.h>

// SDL_Window* window = NULL;
// SDL_Renderer* renderer = NULL;
// SDL_Texture* texture;

// #define KEYQUEUE_SIZE 16

// static unsigned short s_KeyQueue[KEYQUEUE_SIZE];
// static unsigned int s_KeyQueueWriteIndex = 0;
// static unsigned int s_KeyQueueReadIndex = 0;

const doomgeneric = @cImport({
    @cInclude("doomgeneric.h");
});

extern fn bInit(resx: u16, resy: u16) void;

pub fn DG_Init() void {
  bInit(doomgeneric.DOOMGENERIC_RESX, doomgeneric.DOOMGENERIC_RESX);
}

pub fn DG_DrawFrame() void {
  SDL_UpdateTexture(texture, NULL, DG_ScreenBuffer, DOOMGENERIC_RESX*sizeof(uint32_t));

  SDL_RenderClear(renderer);
  SDL_RenderCopy(renderer, texture, NULL, NULL);
  SDL_RenderPresent(renderer);

  handleKeyInput();
}

void DG_SleepMs(uint32_t ms)
{
  SDL_Delay(ms);
}

uint32_t DG_GetTicksMs()
{
  return SDL_GetTicks();
}

int DG_GetKey(int* pressed, unsigned char* doomKey)
{
  if (s_KeyQueueReadIndex == s_KeyQueueWriteIndex){
    //key queue is empty
    return 0;
  }else{
    unsigned short keyData = s_KeyQueue[s_KeyQueueReadIndex];
    s_KeyQueueReadIndex++;
    s_KeyQueueReadIndex %= KEYQUEUE_SIZE;

    *pressed = keyData >> 8;
    *doomKey = keyData & 0xFF;

    return 1;
  }

  return 0;
}

void DG_SetWindowTitle(const char * title)
{
  if (window != NULL){
    SDL_SetWindowTitle(window, title);
  }
}
