#include "cacheblock.h"

uint32_t Cache::Block::get_address() const {
  // TODO
  auto offset_bits = _cache_config.get_num_block_offset_bits();
  auto index_bits = _cache_config.get_num_index_bits();
  auto ret_val = get_tag();

  ret_val = ((ret_val << index_bits) + _index);
  return (ret_val << offset_bits);
}
