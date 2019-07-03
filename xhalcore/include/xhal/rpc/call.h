/*!
 * \file
 * \brief This file contains all the functions needed to call
 * remotely a RPC method
 *
 * \author Laurent Pétré <lpetre@ulb.ac.be>
 */

#ifndef XHAL_RPC_CALL_H
#define XHAL_RPC_CALL_H

#include "xhal/rpc/common.h"
#include "xhal/rpc/compat.h"
#include "xhal/rpc/helper.h"

#include "xhal/rpc/wiscrpcsvc.h" // move the header to xhal/extern/wiscrpcsvc.h ?

#include <typeinfo>

namespace xhal { namespace rpc {

    /*!
     * \brief Remotely call a RPC method
     *
     * The remote method called is defined by the template parameter
     * \c Method. The arguments to give to the function are those from
     * the \c Method::operator() signature and their types \b must be deducible.
     */
    template<typename Method,
             typename... Args,
             typename std::enable_if<std::is_base_of<xhal::rpc::Method, Method>::value, int>::type = 0
            >
    helper::functor_return_t<Method> call(wisc::RPCSvc &connection, Args&&... args)
    {
        // The wisc::RPCMsg method name is taken from the typeid
        // This is implementation dependent but g++ and clang++
        // follow the same convention
        wisc::RPCMsg request(std::string(abiVersion) + "." + typeid(Method).name());
        MessageSerializer query{&request};

        // Type conversion from args to serializable types
        // must be performed in the same statement in order to
        // make use of lifetime extension
        query << helper::get_forward_as_tuple<Method>()(args...);

        // Remote call
        const wisc::RPCMsg response = connection.call_method(request);

        // The RPC method can return a void so the void_holder is required
        compat::void_holder<helper::functor_return_t<Method>> return_v;

        MessageDeserializer reply{&response};
        reply >> return_v;

        return return_v.get();
    }

}}

#endif
