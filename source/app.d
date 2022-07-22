import std.stdio;
import core.time;

import bindbc.sdl;
import bindbc.opengl;
import batch;

void log(string str) {
	writeln("[MAIN] ", str);
}

void main() {
	SDLSupport sdlSupportFlag = loadSDL("SDL2.dll");
	
	if (sdlSupportFlag != sdlSupport) {
		log("Failed to init SDL library.");
	}
	
	log("Initialising SDL.");
	
	SDL_Window* sdlWin;
	sdlWin = SDL_CreateWindow("oi", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 1280, 720, SDL_WINDOW_OPENGL);
	
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
	
	SDL_GLContext sdlGLContext = SDL_GL_CreateContext(sdlWin);
	GLSupport glSupportFlag = loadOpenGL();
	
	bool flagRunning = true;
	
	long elapsedTicks = SDL_GetTicks();
	long currentTicks = 0;
	long ticksGoingOn = 0;
	
	uint fps = 60;
	long intervalTicks = 1000 / fps;
	
	SDL_Event sdlEvent;
	
	while (flagRunning) {
		currentTicks = SDL_GetTicks();
		ticksGoingOn = currentTicks - elapsedTicks;
		
		if (ticksGoingOn > intervalTicks) {
			while (SDL_PollEvent(&sdlEvent)) {
				switch (sdlEvent.type) {
					case SDL_QUIT: {
						flagRunning = false;
						break;
					}
					
					default: {
						break;
					}
				}
			}
			
			glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
			glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
			
			SDL_GL_SwapWindow(sdlWin);
		}
	}
}
