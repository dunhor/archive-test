
#include <algorithm>
#include <charconv>
#include <cstddef>
#include <cstdint>
#include <format>
#include <optional>
#include <print>
#include <random>

#include <Windows.h>

static std::mt19937 eng{ std::random_device()() };

// The data we write to the files comes from this buffer. The goal is to have a decent number of repeating sequences
// of identical bytes of varying lengths
std::byte data_buffer[512];

std::optional<std::size_t> parse_size(const char* data)
{
    auto last = data + ::strlen(data);
    std::size_t result;
    auto [ptr, ec] = std::from_chars(data, last, result);
    if ((ec != std::errc{}) || (ptr != last))
    {
        return std::nullopt;
    }

    return result;
}

int main(int argc, char** argv)
{
    // Initialize the data buffer
    std::uniform_int_distribution<int> byteDist(0, 255);
    for (auto& byte : data_buffer)
    {
        byte = static_cast<std::byte>(byteDist(eng));
    }

    // Arguments are the number of bytes that we want in the file. Files are named 'file0', 'file1', etc.
    for (int i = 1; i < argc; ++i)
    {
        auto size = parse_size(argv[i]);
        if (!size)
        {
            std::println("ERROR: {} is not a number", argv[i]);
            return -1;
        }

        auto filename = std::format(L"file{}", i);
        auto handle = ::CreateFileW(filename.c_str(), GENERIC_READ | GENERIC_WRITE, FILE_SHARE_READ, nullptr,
            CREATE_NEW, FILE_ATTRIBUTE_NORMAL, nullptr);
        if (handle == INVALID_HANDLE_VALUE)
        {
            std::println("ERROR: Failed to create file file{} ({})", i, ::GetLastError());
            return -1;
        }

        std::uniform_int_distribution<std::size_t> lenDist(0, std::size(data_buffer));
        while (*size > 0)
        {
            auto len = static_cast<DWORD>(std::min(*size, lenDist(eng)));

            std::uniform_int_distribution<DWORD> startDist(0, std::size(data_buffer) - len);
            auto start = startDist(eng);

            DWORD bytesWritten;
            if (!::WriteFile(handle, data_buffer + start, len, &bytesWritten, nullptr))
            {
                std::println("ERROR: Failed to write data to file{}", i);
                ::CloseHandle(handle);
                return -1;
            }

            *size -= bytesWritten;
        }

        ::CloseHandle(handle);
    }
}
