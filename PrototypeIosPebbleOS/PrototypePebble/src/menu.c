#include <pebble.h>
#include "menu.h"
#include "connector.h"  

#define NUM_FIRST_MENU_ITEMS 1
#define NUM_SECOND_MENU_ITEMS 1
#define NUM_MENU_SECTIONS 2

static Window *window;
static MenuLayer *menu_layer;
static GBitmap *image_alarm_button;
static GBitmap *image_notify_button;


// A callback is used to specify the amount of sections of menu items
// With this, sections can be dynamically added and removed
static uint16_t menu_get_num_sections_callback(MenuLayer *menu_layer, void *data) {
  return NUM_MENU_SECTIONS;
}

// Each section has a number of items and again a callback is used to specify this
// With this, items can be dynamically added and removed to each section
static uint16_t menu_get_num_rows_callback(MenuLayer *menu_layer, uint16_t section_index, void *data) {
  switch (section_index) {
    case 0:
      return NUM_FIRST_MENU_ITEMS;
    case 1:
      return NUM_SECOND_MENU_ITEMS;
    default:
      return 0;
  }
}

// A callback is used to specify the height of the section header
static int16_t menu_get_header_height_callback(MenuLayer *menu_layer, uint16_t section_index, void *data) {
  // This is a define provided in pebble.h that you may use for the default height
  //return MENU_CELL_BASIC_HEADER_HEIGHT;
  int16_t height = 0;
  switch (section_index) {
    case 0:
      height = 0;
      break;
    case 1:
      height = 20;  
      break; 
  }
  return height;
}

// Here we draw what each header is
static void menu_draw_header_callback(GContext* ctx, const Layer *cell_layer, uint16_t section_index, void *data) {
  // Determine which section we're working with
  switch (section_index) {
    case 0:
      // Do nothing since the first section won't be shown.
      break;
    case 1:
      menu_cell_basic_header_draw(ctx, cell_layer, "up:ALARM/down:Notify");
      break;
  }
}

// Menu cell height fixed to 130
static int16_t menu_get_cell_height_callback(struct MenuLayer *menu_layer, MenuIndex *cell_index, void *data) {
  return 130;
}

// This is the menu item draw callback where you specify what each item should look like
static void menu_draw_row_callback(GContext* ctx, const Layer *cell_layer, MenuIndex *cell_index, void *data) {

  GRect img_bounds = image_alarm_button->bounds;  // Both images have the same size.
  
  // There are two sections and each one of them has one item, therefore the following switch statement construction applies                                                        
  switch (cell_index->section) {
    case 0:
      // Use the row to specify which item we'll draw
      switch (cell_index->row) {
        case 0:
          // Make sure the dimensions of the GRect to draw into are equal to the size of the bitmap, otherwise the image will automatically tile.
          graphics_draw_bitmap_in_rect(ctx, image_alarm_button, (GRect) { .origin = { 17, 10 }, .size = img_bounds.size });
          break;
      }
      break;
    case 1:
      switch (cell_index->row) {
	case 0:
	  graphics_draw_bitmap_in_rect(ctx, image_notify_button, (GRect) { .origin = { 17, 10 }, .size = img_bounds.size });
	  break;
      }
      break;
  }
}

// Executed when a user selects a menu item
void menu_select_callback(MenuLayer *menu_layer, MenuIndex *cell_index, void *data) {
  char *update = "";  // Initialize with empty string    
  switch (cell_index->section) {
    case 0:
      switch (cell_index->row) {
        case 0:
          update = "ALARM";  
          break;
      }
      break;
    case 1:
      switch (cell_index->row) {
        case 0:
          update = "Notification";
          break;
      }
      break;
  }
  send_message(update);
}

static void window_load(Window *window) {
  Layer *window_layer = window_get_root_layer(window);
  GRect bounds = layer_get_bounds(window_layer);
  
  image_alarm_button = gbitmap_create_with_resource(RESOURCE_ID_IMAGE_ALARM_BUTTON);
  image_notify_button = gbitmap_create_with_resource(RESOURCE_ID_IMAGE_NOTIFY_BUTTON);

  menu_layer = menu_layer_create(bounds); 

  // Hide the shadow of the scroll layer                                       
  scroll_layer_set_shadow_hidden(menu_layer_get_scroll_layer(menu_layer), true);

  // Set all the callbacks for the menu layer. Note that the order of callbacks is important.
  menu_layer_set_callbacks(menu_layer, NULL, (MenuLayerCallbacks){
    .get_num_sections = menu_get_num_sections_callback,        
    .get_num_rows = menu_get_num_rows_callback,                
    .get_header_height = menu_get_header_height_callback,
    .draw_header = menu_draw_header_callback,
    .get_cell_height = menu_get_cell_height_callback,
    .draw_row = menu_draw_row_callback,                            
    .select_click = menu_select_callback,                    
  });

  // Bind the menu layer's click config provider to the window for interactivity
  menu_layer_set_click_config_onto_window(menu_layer, window);  

  layer_add_child(window_layer, menu_layer_get_layer(menu_layer));
}

static void window_unload(Window *window) { 
  gbitmap_destroy(image_alarm_button);
  gbitmap_destroy(image_notify_button);
  menu_layer_destroy(menu_layer);  
}

void show_menu(void) {
  window_stack_push(window, true);
}

void menu_init(void) {
  window = window_create();
  window_set_window_handlers(window, (WindowHandlers) {
    .load = window_load,
    .unload = window_unload
  });
}

void menu_deinit(void) {
  window_destroy(window);
}


