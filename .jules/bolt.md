## 2024-05-24 - Expensive Computations in Getters
**Learning:** Found a performance pattern where a list view builder used a getter `_filteredAudios` which re-evaluated O(N log N) sorting and O(N) string filtering on every `build` (which happens frequently e.g. when selecting an item from the list).
**Action:** Caching such computations into variables and updating them only when the dependencies change (search query, sort toggle, data itself) significantly reduces main thread blocking. Always look for expensive computations inside getters used directly in `build` methods.
