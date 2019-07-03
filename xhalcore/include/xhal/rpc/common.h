/*!
 * \file
 * \brief Contains the classes required for defining remotely callable RPC methods
 *
 * \author Laurent Pétré <lpetre@ulb.ac.be>
 */

#ifndef XHAL_RPC_COMMON_H
#define XHAL_RPC_COMMON_H

#include "xhal/rpc/compat.h"

#include <cstdint>
#include <string>
#include <vector>

#include "xhal/rpc/wiscRPCMsg.h" // move the header to "xhal/extern/wiscRPCMsg.h" ?

namespace xhal { namespace rpc {

    /*!
     * \brief Defines the templated RPC ABI version
     */
    static constexpr const char* abiVersion = "v1";

    /*!
     * \brief Class whose all remotely callable RPC method must inherit from
     *
     * The required inheritance is used as a compile time check so a developer
     * cannot remotely call a local function by mistake.
     */
    struct Method
    {
        /*!
         * \brief The operator call must be define <b>once and only once</b> per
         * RPC method.
         *
         * This templated operator declaration is only shown as an example and
         * emphasizes the need of defining it in child classes.
         *
         * \warnng The call operator \b must be defined as \c const.
         */
        template<typename R, typename... Args> R operator()(Args...) const;
    };

    /*!
     * \brief Base of the \c MessageSerializer and \c MessageDeserializer classes
     *
     * \c MessageBase provides the key index tracking functionnality which
     * is mandatory for serialization.
     */
    class MessageBase {

        /*!
         * \brief Index to the next free/unread key
         */
        uint32_t _keyIdx = 0;

      protected:

        /*
         * \brief Returns the next free/unread key
         */
        inline uint32_t dispenseKey() { return _keyIdx++; }

    };

    /*!
     * \brief This class serializes parameters into a \c wisc::RPCMsg
     */
    class MessageSerializer : public MessageBase
    {

    protected:

        wisc::RPCMsg *m_wiscMsg;

        /*
         * \brief Supresses implicit type conversions
         *
         * Every type not defined hereunder is delete by this templated function.
         * It aims at enforcing maximum type compatibility with the UW RPC API by
         * remembering the developer that she/he can transmit defined types over the
         * network.
         */
        template<typename T> void save(T) = delete;

        /*!
         * \brief Adds a \c std::uint32_t to the message
         */
        inline void save(const std::uint32_t value) {
            m_wiscMsg->set_word(std::to_string(dispenseKey()), value);
        }

        /*!
         * \brief Adds a \c std::vector<std::uint32_t> to the message
         */
        inline void save(const std::vector<std::uint32_t> &value) {
            m_wiscMsg->set_word_array(std::to_string(dispenseKey()), value);
        }

        /*!
         * \brief Adds a \c std::string to the message
         */
        inline void save(const std::string &value) {
            m_wiscMsg->set_string(std::to_string(dispenseKey()), value);
        }

        /*!
         * \brief Adds a \c std::vector<std::string> to the message
         */
        inline void save(const std::vector<std::string> &value) {
            m_wiscMsg->set_string_array(std::to_string(dispenseKey()), value);
        }

        /*!
         * \brief Adds the content of a \c void_holder to the message
         *
         * It should be used when setting the result from a function call.
         */
        template<typename T> inline void save(const compat::void_holder<T> &holder) {
            this->save(holder.get());
        }

        /*!
         * \brief Specialization for the \c void special case
         */
        inline void save(compat::void_holder<void>) {}

        /*!
         * \brief Serializes the arguments from a \c std::tuple
         *
         * \c std::tuple content is add from left to right to the message
         * via a recursive template. It should be to serialize function arguments.
         */
        template<std::size_t I = 0,
                 typename... Args,
                 typename std::enable_if<I < sizeof...(Args), int>::type = 0
                >
        inline void save(const std::tuple<Args...> &args) {
            this->save(std::get<I>(args));
            this->save<I+1>(args);
        }

        /*!
         * \brief Terminal call
         */
        template<std::size_t I = 0,
                 typename... Args,
                 typename std::enable_if<I == sizeof...(Args), int>::type = 0
                >
        inline void save(const std::tuple<Args...> &) {}

    public:

        /*!
         * \brief Constructor
         *
         * Data are serialized into the \c wiscMsg message.
         */
        explicit MessageSerializer(wisc::RPCMsg *wiscMsg) noexcept : m_wiscMsg{wiscMsg} {}

        /*!
         * \brief Allows to serialize data into the message with a natural interface
         */
        template<typename T>
        MessageSerializer & operator<<(const T &t) {
            this->save(t);
            return *this;
        }

        /*!
         * \brief Behaves as \c operator<<
         *
         * Is used for providing a unifed interface between \c MessageSerializer and
         * \c MessageDeserializer so custom types serialization can be defined in a single
         * function.
         */
        template<typename T>
        MessageSerializer & operator&(const T &t) {
            this->save(t);
            return *this;
        }

    };

    /*!
     * \brief This class deserializes parameters from a \c wisc::RPCMsg
     *
     * While it cannot be made \c const because deserializing requires to keep
     * track of the state, this class guarentees that the original \c wisc::RPCMsg
     * object will remain untouched.
     */
    class MessageDeserializer : public MessageBase {

    protected:

        const wisc::RPCMsg *m_wiscMsg;

        /*
         * \brief Supresses implicit type conversion
         *
         * Every type not defined hereunder is delete by this templated function.
         * It aims at enforcing maximum type compatibility with the UW RPC API by
         * remembering the developer that she/he can transmit defined types over the
         * network.
         */
        template<typename T> void load(T) = delete;

        /*!
         * \brief Retrieves a \c std::uint32_t from the message
         */
        inline void load(uint32_t &value) {
            value = m_wiscMsg->get_word(std::to_string(dispenseKey()));
        }

        /*!
         * \brief Retrieves a \c std::vector<std::uint32_t> from the message
         */
        inline void load(std::vector<std::uint32_t> &value) {
            value = m_wiscMsg->get_word_array(std::to_string(dispenseKey()));
        }

        /*!
         * \brief Retrieves a \c std::string from the message
         */
        inline void load(std::string &value) {
            value = m_wiscMsg->get_string(std::to_string(dispenseKey()));
        }

        /*!
         * \brief Retrieves a \c std::vector<std::string> from the message
         */
        inline void load(std::vector<std::string> & value) {
            value = m_wiscMsg->get_string_array(std::to_string(dispenseKey()));
        }

        /*!
         * \brief Retrieve a \c T parameter from the message and stores it inside
         * a \c void_holder.
         *
         * It should be used when setting the result from a function.
         */
        template<typename T> inline void load(compat::void_holder<T> &value) {
            this->load(value.get());
        }

        /*!
         * \brief Specialization for the \c void special case
         */
        inline void load(compat::void_holder<void>) {}

        /*!
         * \brief Fills in a \c std::tuple with data from the message
         *
         * \c std::tuple content is filled from left to right from the message
         * via a recursive template. It should be use to deserialize function
         * arguments.
         */
        template<std::size_t I = 0,
                 typename... Args,
                 typename std::enable_if<I < sizeof...(Args), int>::type = 0
                >
        inline void load(std::tuple<Args...> &args) {
            this->load(std::get<I>(args));
            this->load<I+1>(args);
        }

        /*!
         * \brief Terminal call
         */
        template<std::size_t I = 0,
                 typename... Args,
                 typename std::enable_if<I == sizeof...(Args), int>::type = 0
                >
        inline void load(const std::tuple<Args...> &) { }

    public:

        /*!
         * \brief Constructor
         *
         * Data are retrieved from the provided \c wiscMsg message.
         */
        explicit MessageDeserializer(const wisc::RPCMsg *wiscMsg) noexcept : m_wiscMsg{wiscMsg} {}

        /*!
         * \brief Allows to deserialiaze data from the message with a natural interface
         */
        template <typename T>
        MessageDeserializer & operator>>(T &t) {
            this->load(t);
            return *this;
        }

        /*!
         * \brief Behaves as \c operator<<
         *
         * Is used for providing a unifed interface between \c MessageSerializer and
         * \c MessageDeserializer so custom types serialization can be defined in a single
         * function.
         */
        template <typename T>
        MessageDeserializer & operator&(T &t) {
            load(t);
            return *this;
        }

    };

} }

#endif
