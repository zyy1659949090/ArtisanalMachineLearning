
# PUT ROXYGEN HERE
#' @param sizes Vector of integer values corresponding to layer sizes 
#' @param training_data Data for training network, 
#' dimension nxp where p is sizes[1]
#' @export
aml_neural_network <- function(sizes, learning_rate, data = NULL, epochs = NULL){
    .test_neural_network_input(sizes)

    # TEST RUNNING - following book example

    sizes = c(1,2,1,1)

    data = data.frame(x = rnorm(15), y = runif(15))

    epochs = 1

    learning_rate = .1

    initial_network = .initialize_random_network(sizes)

    initial_network$weights[[1]] = matrix(c(.1, .2, .3, .4), 2, 2, byrow = TRUE)

    initial_network$weights[[2]] = matrix(c(.2, 1, -3))

    initial_network$weights[[3]] = matrix(1:2)

    data_obs = c(2)
    response = 1

    processed_network = .back_propogation(initial_network, data_obs, epochs, learning_rate)

}

################################################################################

.test_neural_network_input <- function(sizes){
    if(length(sizes) < 2){
        stop(paste("Argument sizes must have more than 1 layer. Did you forget",
                   "to include the input or output layers?"))
    }
    if(!is.numeric(sizes)){
        stop("Argument sizes must be numeric vector of integers")
    }
    if(!all(as.integer(sizes) == sizes)){
        stop("Argument sizes must be vector of integers")
    }
}

.calculate_transformation <- function(z){
    tanh(z)
}

.calculate_transformation_prime <- function(z){
    1 - tanh(z)^2
}

.initialize_random_network <- function(sizes){
    layers = length(sizes)
    weights = lapply(2:layers, function(index){
        # Add one for bias term
        number_of_nodes_in_previous_layer = sizes[index - 1] + 1
        number_of_nodes_in_current_layer = sizes[index]
        weight_list = lapply(1:number_of_nodes_in_previous_layer, function(x){
            rnorm(number_of_nodes_in_current_layer)
        })
        do.call(rbind, weight_list)
    })

    output = list(sizes = sizes, 
                  layers = layers, 
                  weights = weights)
    output = .prepend_class(output, "aml_neural_network")
    output
}

.feed_forward <- function(network, observation){
    network_output = lapply(1:length(network$weights), function(x){
        .calculate_activations(network, observation, x)
    })
    network_output
}

.calculate_activations <- function(network, observation, layer){
    if(layer == 1){
        # Cat observation with 1 for the bias term
        s = t(network$weights[[layer]]) %*% as.matrix(c(1, observation))
        output = .calculate_transformation(s)
    }else{
        s = t(network$weights[[layer]]) %*% 
            as.matrix(c(1, .calculate_activations(network, observation, layer - 1)$output))
        output = .calculate_transformation(s)
    }
    list(output = output, s = s)
}

.back_propogation <- function(network, data, epochs, learning_rate){
    # FIX THIS
    # data_obs = 
    # response = 
    for(epoch_number in 1:epochs){
        print(paste("Epoch: ", epoch_number))

        activations = .feed_forward(network, as.matrix(data_obs))

        deltas = .compute_deltas(network, activations, response)

        partial_derivatives = .calculate_partial_derivatives(activations, deltas, data_obs)

        network = .update_network(network, partial_derivatives, learning_rate)
    }
    network
}

.update_network <- function(network, partial_derivatives, learning_rate){
    for(i in 1:length(network$weights)){
        network$weights[[i]] = network$weights[[i]] + learning_rate * partial_derivatives[[i]]
    }
    network
}

.compute_deltas <- function(network, activations, response){
    deltas = list()
    for(i in (network$layers - 1):1){
        if(i == (network$layers - 1)){
            deltas[[i]] = 2 * (activations[[i]]$output - response) * 
                .calculate_transformation_prime(activations[[i]]$s)
        }else{
            deltas[[i]] = (1 - activations[[i]]$output ^ 2) *
                as.matrix(network$weights[[i + 1]][-1,]) %*% deltas[[i + 1]] 
        }
    }
    deltas
}

.calculate_partial_derivatives <- function(activations, deltas, data_obs){
    partial_derivatives = list()
    for(i in 1:length(activations)){
        if(i == 1){
            partial_derivatives[[i]] = matrix(c(1,data_obs))%*% t(deltas[[i]])
        }else{
            partial_derivatives[[i]] = matrix(c(1, activations[[i - 1]]$output)) %*% t(deltas[[i]])  
        }
    }
    partial_derivatives
}
