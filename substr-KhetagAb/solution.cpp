#include <string>
#include <cstring>

size_t next_pref(const char* str, const size_t* p_func, size_t j, char c) {
    while (j > 0 && c != str[j]) {
        j = p_func[j - 1];
    }

    return (j + (c == str[j]));
}

int main(int argc, char** argv) {
    if (argc != 3) {
        std::fprintf(stderr, "Usage: [file_name] [substring]\n");
        return -1;
    }

    const char* input_file = argv[1];
    FILE* in = std::fopen(input_file, "rb");

    if (!in) {
        std::fprintf(stderr, "Cannot open file: %s\n", input_file);
        return -1;
    }

    const char* pattern = argv[2];
    size_t pattern_len = std::strlen(pattern);

    size_t* p_func = (size_t *) std::malloc(pattern_len * sizeof(size_t));
    if (!p_func){
        std::fprintf(stderr, "Something wrong with memory allocation!\n");
        std::fclose(in);
        return -1;
    }

    bool pattern_found = false;
    p_func[0] = 0;
    size_t last = 0;
    int c;
    for (size_t i = 1; i < pattern_len || (c = std::fgetc(in)) != EOF; i++) { // clever || solves!
        last = next_pref(pattern, p_func, last, (i < pattern_len) ? pattern[i] : (char) c);
        if (i < pattern_len) {
            p_func[i] = last;
        } else if (last == pattern_len) {
            pattern_found = true;
            break;
        }
    }

    std::free(p_func);

    if (pattern_found) {
        std::fprintf(stdout, "Yes\n");
    } else {
        std::fprintf(stdout, "No\n");
    }

    if (std::ferror(in)) {
        std::fprintf(stderr, "Cannot read the file\n");
        std::fclose(in);
        return -1;
    }

    std::fclose(in);

    return 0;
}
