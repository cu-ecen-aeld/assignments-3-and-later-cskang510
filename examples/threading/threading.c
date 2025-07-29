#include "threading.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

// Optional: use these functions to add debug or error prints to your application
//#define DEBUG_LOG(msg,...)
#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)

void* threadfunc(void* thread_param)
{

    // TODO: wait, obtain mutex, wait, release mutex as described by thread_data structure
    // hint: use a cast like the one below to obtain thread arguments from your parameter
    //struct thread_data* thread_func_args = (struct thread_data *) thread_param;
    struct thread_data* thread_func_args = (struct thread_data *) thread_param;
    DEBUG_LOG("Thread started with wait_to_obtain_ms: %u, wait_to_release_ms: %u",
              thread_func_args->wait_to_obtain_ms, thread_func_args->wait_to_release_ms);
    // Sleep for the specified time before obtaining the mutex
    usleep(thread_func_args->wait_to_obtain_ms * 1000); // Convert milliseconds to microseconds
    DEBUG_LOG("Thread attempting to obtain mutex");
    pthread_mutex_lock(thread_func_args->mutex);
    DEBUG_LOG("Thread obtained mutex");
    // Sleep for the specified time while holding the mutex
    usleep(thread_func_args->wait_to_release_ms * 1000); // Convert milliseconds to microseconds
    pthread_mutex_unlock(thread_func_args->mutex);
    DEBUG_LOG("Thread released mutex");
    // Indicate that the thread completed successfully
    thread_func_args->thread_complete_success = true;
    // Return the thread_data structure to the joiner thread
    DEBUG_LOG("Thread exiting");

    return thread_param;
}

bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,int wait_to_obtain_ms, int wait_to_release_ms)
{
    /**
     * TODO: allocate memory for thread_data, setup mutex and wait arguments, pass thread_data to created thread
     * using threadfunc() as entry point.
     *
     * return true if successful.    // Note: The thread will automatically clean up its resources when it exits.
     *
     * See implementation details in threading.h file comment block
     */
    struct thread_data *data = malloc(sizeof(struct thread_data));
    if (data == NULL) {
        ERROR_LOG("Failed to allocate memory for thread_data");
    }
    data->thread_complete_success = false;
    // Set up the thread data with the wait times
    data->wait_to_obtain_ms = wait_to_obtain_ms;
    data->wait_to_release_ms = wait_to_release_ms;

    // Set the mutex pointer to the provided mutex
    data->mutex = mutex;

    // Create the thread
    int result = pthread_create(thread, NULL, threadfunc, (void *)data);
    if (result != 0) {
        ERROR_LOG("Failed to create thread: %s", strerror(result));
        free(data);
        return false;
    }
    
    return true;
}