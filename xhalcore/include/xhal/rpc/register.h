/*!
 * \file
 * \brief This file contains all the functions needed to register
 * a remotely callable RPC method
 *
 * \author Laurent Pétré <lpetre@ulb.ac.be>
 */

#ifndef XHAL_RPC_REGSTER_H
#define XHAL_RPC_REGSTER_H

#include "xhal/rpc/common.h"
#include "xhal/rpc/compat.h"
#include "xhal/rpc/helper.h"

#include "moduleapi.h" // Only present in the CTP7 modules

#include <typeinfo>

namespace xhal { namespace rpc {

    /*!
     * \brief Locally invoke a RPC method
     *
     * This function is the wrapper called for every remote function call. It
     * deserializes the arguments from the \c wisc::RPCMsg, calls the local functor
     * and then serializes the return value to the \c wisc::RPCMsg.
     */
    template<typename Method,
             typename std::enable_if<std::is_base_of<xhal::rpc::Method, Method>::value, int>::type = 0
            >
    void invoke(const wisc::RPCMsg *request, wisc::RPCMsg *response) noexcept
    {
        // Remove the cv-qualifiers and references since we need
        // a copy of the object
        helper::functor_decay_args_t<Method> args;

        MessageDeserializer query(request);
        query >> args;

        // Call the Method functor with the arguments received from
        // the RPC message
        auto result = compat::tuple_apply<helper::functor_return_t<Method>>(Method{}, args);

        // Serialize the reply
        MessageSerializer reply(response);
        reply << result;
    }

    /*!
     * \brief Register a RPC method into the \c ModuleManager
     *
     * This helper function register a RPC method with the right parameters
     * so it can be remotely called.
     */
    template<typename Method>
    void registerMethod(ModuleManager *modmgr)
    {
        // The method name is taken from the typeid
        // This is implementation dependent but g++ and clang++
        // follow the same convention
        return modmgr->register_method(abiVersion,
                                       typeid(Method).name(),
                                       xhal::rpc::invoke<Method>);
    }

}}

#endif
