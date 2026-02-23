/* Dummy C file to force inclusion of Fortran symbol auto_main_c when linking
	the shared library. We reference the Fortran symbol without calling it.
*/
extern void auto_main_c(void);

void auto_shared_dummy(void) {}

/* Reference the Fortran symbol so the linker pulls the archive member. */
volatile int auto_shared_flag = 0;
void auto_shared_ref(void) { if(auto_shared_flag) auto_main_c(); }
