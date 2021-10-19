#pragma once

#include <cstddef>

template <typename T>
struct vector {
  using iterator = T*;
  using const_iterator = T const*;

  // O(1) nothrow
  vector() = default;

  // O(N) strong
  vector(vector const& other) : vector() {
    copy_from(other.data_, other.size_, other.size_);
  }

  // O(N) strong
  vector& operator=(vector const& other) {
    if (this != &other) {
      vector(other).swap(*this);
    }
    return *this;
  }

  // O(N) nothrow
  ~vector() {
    clear();

    operator delete(data_);
  }

  // O(1) nothrow
  T& operator[](size_t i) {
    return data_[i];
  }

  // O(1) nothrow
  T const& operator[](size_t i) const {
    return data_[i];
  }

  // O(1) nothrow
  T* data() {
    return data_;
  }

  // O(1) nothrow
  T const* data() const {
    return data_;
  }

  // O(1) nothrow
  size_t size() const {
    return size_;
  }

  // O(1) nothrow
  T& front() {
    return *data_;
  }

  // O(1) nothrow
  T const& front() const {
    return *data_;
  }

  // O(1) nothrow
  T& back() {
    return data_[size_ - 1];
  }

  // O(1) nothrow
  T const& back() const {
    return data_[size_ - 1];
  }

  // O(1) strong
  void push_back(T const& t) {
    if (size_ == capacity_) {
      T t_cpy = t;
      reserve(capacity_ == 0 ? 1 : capacity_ * 2);
      new (data_ + size_) T(t_cpy);
    } else {
      new (data_ + size_) T(t);
    }

    size_++;
  }

  // O(1) nothrow
  void pop_back() {
    data_[--size_].~T();
  }

  // O(1) nothrow
  bool empty() const {
    return size_ == 0;
  }

  // O(1) nothrow
  size_t capacity() const {
    return capacity_;
  }

  // O(N) strong
  void reserve(size_t new_capacity) {
    if (capacity_ < new_capacity) {
      ensure_capacity(new_capacity);
    }
  }

  // O(N) strong
  void shrink_to_fit() {
    ensure_capacity(size_);
  }

  // O(N) nothrow
  void clear() {
    erase(begin(), end());
  }

  // O(1) nothrow
  void swap(vector& other) {
    std::swap(data_, other.data_);
    std::swap(size_, other.size_);
    std::swap(capacity_, other.capacity_);
  }

  // O(1) nothrow
  iterator begin() {
    return data_;
  }

  // O(1) nothrow
  iterator end() {
    return (data_ + size_);
  }

  // O(1) nothrow
  const_iterator begin() const {
    return data_;
  }

  // O(1) nothrow
  const_iterator end() const {
    return (data_ + size_);
  }

  // O(N) strong
  iterator insert(const_iterator pos, T const& val) {
    ptrdiff_t ind = pos - begin();
    push_back(val);

    for (size_t i = size_ - 1; i - ind > 0; i--) {
      std::swap(data_[i], data_[i - 1]);
    }

    return begin() + ind;
  }

  // O(N) nothrow(swap)
  iterator erase(const_iterator pos) {
    return erase(pos, pos + 1);
  }

  // O(N) nothrow(swap)
  iterator erase(const_iterator first,
                 const_iterator last) {
    ptrdiff_t ind = first - begin();

    if (first <= last) {
      ptrdiff_t swaps = last - first;

      for (size_t i = ind; i + swaps < size_; i++) {
        std::swap(data_[i], data_[i + swaps]);
      }

      while (swaps-- > 0) {
        pop_back();
      }
    }

    return begin() + ind;
  }

private:
  void ensure_capacity(const size_t new_capacity) {
    if (capacity_ != new_capacity) {
      copy_from(data_, size_, new_capacity);
    }
  }

  void copy_from(T* const data_from, const size_t len, const size_t new_capacity) {
    if (len <= new_capacity) {
      T* buffer = new_capacity == 0 ? nullptr : static_cast<T*>(operator new(new_capacity * sizeof(T)));

      size_t constr_count = 0;
      try {
        for (; constr_count < len; constr_count++) {
          new (buffer + constr_count) T(data_from[constr_count]);
        }
      } catch (...) {
        while (constr_count > 0) {
          (buffer + --constr_count)->~T();
        }
        operator delete(buffer);
        throw;
      }

      clear();
      operator delete (data_);

      data_ = buffer;
      size_ = constr_count;
      capacity_ = new_capacity;
    }
  }

  T* data_{nullptr};
  size_t size_{0};
  size_t capacity_{0};
};
