/* Not all environments have a working getenv()/putenv() */

extern(C):

/* Put a variable of the form "name=value" into the environment */
int putenv(const char *variable);
int SDL_putenv(const char *X) { return putenv(X); }

/* Retrieve a variable named "name" from the environment */
char *getenv(const char *name);
char *SDL_getenv(const char *X) { return getenv(X); }
