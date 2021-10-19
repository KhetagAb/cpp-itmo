#include <cassert>  // assert
#include <iterator> // std::reverse_iterator
#include <utility>  // std::pair, std::swap

template <typename T>
struct set {
  struct iterator;
  using const_iterator = iterator;
  using reverse_iterator = std::reverse_iterator<iterator>;
  using const_reverse_iterator = std::reverse_iterator<const_iterator>;

  struct node {
    node* left;
    node* right;
    node* parent;

    node() : left(nullptr), right(nullptr), parent(nullptr) {}
    node(node* left, node* right, node* parent)
        : left(left), right(right), parent(parent) {}

    virtual ~node() = default;
  };

  struct data_node : node {
    const T data;

    data_node(const T& data, node* left, node* right, node* parent)
        : node(left, right, parent), data(data) {
      if (left != nullptr) {
        left->parent = this;
      }
      if (right != nullptr) {
        right->parent = this;
      }
    }

    ~data_node() = default;
  };

  struct iterator {
    using iterator_category = std::bidirectional_iterator_tag;
    using difference_type = std::ptrdiff_t;
    using value_type = T const;
    using pointer = T const*;
    using reference = T const&;

    iterator() : ptr(nullptr) {}
    explicit iterator(node* node) : ptr(node) {}
    iterator(iterator const& other) : ptr(other.ptr) {}

    ~iterator() = default;

    // O(1) nothrow
    reference operator*() const {
      return static_cast<data_node*>(ptr)->data;
    }

    // O(1) nothrow
    pointer operator->() const {
      return &(static_cast<data_node*>(ptr)->data);
    }

    //      nothrow
    iterator& operator++() & {
      ptr = next(ptr);
      return *this;
    }

    //      nothrow
    iterator operator++(int) & {
      iterator tmp(ptr);
      ++(*this);
      return tmp;
    }

    //      nothrow
    iterator& operator--() & {
      ptr = prev(ptr);
      return *this;
    }

    //      nothrow
    iterator operator--(int) & {
      iterator tmp(ptr);
      --(*this);
      return tmp;
    }

    bool operator==(iterator const& b) {
      return (ptr == b.ptr);
    }

    bool operator!=(iterator const& b) {
      return (ptr != b.ptr);
    }

    friend bool operator==(iterator const& a, iterator const& b) {
      return (a.ptr == b.ptr);
    }

    friend bool operator!=(iterator const& a, iterator const& b) {
      return (a.ptr != b.ptr);
    }

    node* ptr;
  };

  node root;
  node* fictive_root = &root;

  // O(1) nothrow
  set() = default;

  // O(n) strong
  set(set const& other) : set() {
    for (auto it = other.begin(); it != other.end(); it++) {
      insert(*it);
    }
  }

  // O(n) strong
  set& operator=(set const& other) {
    set temp(other);
    this->swap(temp);
    return *this;
  }

  // O(n) nothrow
  ~set() {
    clear();
  };

  // O(n) nothrow
  void clear() {
    destroy_tree(fictive_root->left);
    fictive_root->left = nullptr;
  };

  // O(1) nothrow
  bool empty() {
    return fictive_root->left == nullptr;
  }

  //      nothrow
  const_iterator begin() const {
    auto current_node = fictive_root;

    while (current_node->left != nullptr) {
      current_node = current_node->left;
    }

    return const_iterator(current_node);
  };

  //      nothrow
  const_iterator end() const {
    return const_iterator(fictive_root);
  }

  //      nothrow
  const_reverse_iterator rbegin() const {
    return const_reverse_iterator(end());
  }

  //      nothrow
  const_reverse_iterator rend() const {
    return const_reverse_iterator(begin());
  }

  // O(h) strong
  std::pair<iterator, bool> insert(T const& data) {
    auto found = find(data);
    if (found == end()) {
      if (fictive_root->left == nullptr) {
        fictive_root->left = new data_node(data, nullptr, nullptr, fictive_root);
      } else {
        insert(fictive_root->left, data);
      }
      return std::make_pair(const_iterator(fictive_root->left), true);
    } else {
      return std::make_pair(const_iterator(found), false);
    }
  }

  // O(h) nothrow
  iterator erase(iterator it) {
    if (it == end()) {
      throw std::runtime_error("Trying to erase end()");
    } else {
      node *to_delete = static_cast<node*>(it.ptr);
      node* parent = to_delete->parent;
      iterator result = ++it;

      node *new_node = nullptr;
      if (to_delete->right != nullptr) {
        new_node = to_delete->right;

        node *down = leftest(new_node);
        down->left = to_delete->left;
        if (to_delete->left != nullptr) {
          to_delete->left->parent = down;
        }

      } else {
        new_node = to_delete->left;
      }

      if (parent->left == to_delete) {
        parent->left = new_node;
      } else {
        parent->right = new_node;
      }

      if (new_node != nullptr) {
        new_node->parent = parent;
      }

      delete to_delete;

      return result;
    }
  }

  // O(h) strong
  const_iterator find(T const& data) const {
    return find(fictive_root->left, data);
  }

  // O(h) strong
  const_iterator lower_bound(T const& data) const {
    node *temp = fictive_root->left;
    node * res = nullptr;

    while (temp != nullptr) {
      if (static_cast<data_node*>(temp)->data < data) {
        temp = temp->right;
      } else {
        res = temp;
        if (temp->left == nullptr) {
          break;
        } else {
          temp = temp->left;
        }
      }
    }

    if (res == nullptr) {
      return end();
    } else {
      return const_iterator(res);
    }
  }

  // O(h) strong
  const_iterator upper_bound(T const& data) const {
    const_iterator lb = lower_bound(data);

    if (find(data) == end()) {
      return lb;
    } else {
      return ++lb;
    }
  }

  // O(1) nothrow
  void swap(set& other) {
    std::swap(root, other.root);
    if (fictive_root->left != nullptr) {
      fictive_root->left->parent = &root;
    }
    if (other.fictive_root->left != nullptr) {
      other.fictive_root->left->parent = &other.root;
    }
  }

private:
  static node* next(node* v) {
    if (v->right != nullptr) {
      return leftest(v->right);
    } else {
      node* tmp = v->parent;

      while (tmp != nullptr && v == tmp->right) {
        v = tmp;
        tmp = tmp->parent;
      }
      return tmp;
    }
  }

  static node* prev(node* v) {
    if (v->left != nullptr) {
      return rightest(v->left);
    } else {
      node* tmp = v->parent;

      while (tmp != nullptr && v == tmp->left) {
        v = tmp;
        tmp = tmp->parent;
      }
      return tmp;
    }
  }

  static node* leftest(node* v) {
    if (v->left == nullptr) {
      return v;
    } else {
      return leftest(v->left);
    }
  }

  static node* rightest(node* v) {
    if (v->right == nullptr) {
      return v;
    } else {
      return rightest(v->right);
    }
  }

  void insert(node* c_root, const T& data) {
    while (c_root != nullptr) {
      if (static_cast<data_node*>(c_root)->data < data) {
        if (c_root->right != nullptr) {
          c_root = c_root->right;
        } else {
          c_root->right = new data_node(data, nullptr, nullptr, c_root);
          return;
        }
      } else {
        if (c_root->left != nullptr) {
          c_root = c_root->left;
        } else {
          c_root->left = new data_node(data, nullptr, nullptr, c_root);
          return;
        }
      }
    }
  }

  const_iterator find(node* c_root, const T& data) const {
    if (c_root == nullptr) {
      return end();
    }

    if (data < static_cast<data_node*>(c_root)->data) {
      return find(c_root->left, data);
    } else {
      if (static_cast<data_node*>(c_root)->data < data) {
        return find(c_root->right, data);
      } else {
        return const_iterator(c_root);
      }
    }
  }

  void destroy_tree(node* node) {
    if (node == nullptr) {
      return;
    }

    destroy_tree(node->left);
    destroy_tree(node->right);

    delete node;
  }
};

template <typename T>
void swap(set<T>& a, set<T>& b) {
  a.swap(b);
}