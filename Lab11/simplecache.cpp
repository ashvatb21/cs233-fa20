#include "simplecache.h"

int SimpleCache::find(int index, int tag, int block_offset) {
  // read handout for implementation details

  auto elem = _cache.find(index);

  if (elem != _cache.end()) {
    auto elem_second = elem->second;

    for (int i = 0; i < elem_second.size(); i++) {

      if (elem_second[i].tag() == tag && elem_second[i].valid()) {
        return elem_second[i].get_byte(block_offset);
      }
    }
  }

  return 0xdeadbeef;
}

void SimpleCache::insert(int index, int tag, char data[]) {
  // read handout for implementation details
  // keep in mind what happens when you assign (see "C++ Rule of Three")

  auto elem = _cache.find(index);

  if (elem != _cache.end()) {
    bool rewrite = true;
    auto & elem_second = elem->second;

    for (int i = 0; i < elem_second.size(); i++) {

      if (elem_second[i].valid() == false) {
        elem_second[i].replace(tag, data);
        rewrite = false;
        return;
      }
    }

    if (rewrite) {
      elem_second[0].replace(tag, data);
    }
  }
}
