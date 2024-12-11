#!/bin/bash

export AIGW_PORT="8080"

echo "Starting the Gloo AI Gateway Prompt Management Demo..."
echo

# Step 1: Configure a simple route to openai LLM backend
read -p "Step 1: Configure a simple route to openai LLM backend. Press enter to proceed..."
kubectl create secret generic openai-secret -n gloo-system \
--from-literal="Authorization=Bearer $OPENAI_API_KEY" \
--dry-run=client -oyaml | kubectl apply -f -
kubectl apply -f route
echo
cat route/*.yaml
echo
echo "Route applied successfully."
echo

# Step 2: Get AI Gateway Load Balancer Address
read -p "Step 2: Retrieve the AI Gateway Load Balancer address. Press enter to proceed..."
export GATEWAY_IP=$(kubectl get svc -n gloo-system gloo-proxy-ai-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}{.status.loadBalancer.ingress[0].hostname}')
echo "Gateway IP: $GATEWAY_IP"

# Step 3: Test OpenAI endpoint
echo
echo "Testing OpenAI endpoint with a simple math question "what is 10+10?""

while true; do
  read -p "Press Enter to send a request, or type 'next' to move on: " user_input
  if [[ "$user_input" == "next" ]]; then
    echo "Step 3 complete."
    echo
    break
  fi

  echo "Sending request to OpenAI endpoint..."
  curl http://$GATEWAY_IP:$AIGW_PORT/openai -H "Content-Type: application/json" -d '{
      "model": "gpt-4o-mini",
      "messages": [
        {
          "role": "user",
          "content": "What is 10+10?"
        }
      ]
    }'
  echo
  echo "^^^^"
  echo "OpenAI should respond with the answer of 10+10 in the response above"
  echo
done

# Step 4: Configure organization-level prompts
read -p "Step 4: Prepend or Append organization-level prompts using a RouteOption. Press enter to proceed..."
kubectl apply -f prompt-management/no-math
echo
cat prompt-management/no-math/*.yaml
echo
echo "RouteOption applied successfully."

# Step 5: Test OpenAI endpoint
echo
echo "Testing OpenAI endpoint with a simple math question "what is 10+10?" with prompt injections applied"

while true; do
  read -p "Press Enter to send a request, or type 'next' to move on: " user_input
  if [[ "$user_input" == "next" ]]; then
    echo "Step 5 complete."
    echo
    break
  fi

  echo "Sending request to OpenAI endpoint..."
  curl http://$GATEWAY_IP:$AIGW_PORT/openai -H "Content-Type: application/json" -d '{
      "model": "gpt-4o-mini",
      "messages": [
        {
          "role": "user",
          "content": "What is 10+10?"
        }
      ]
    }'
  echo
  echo "^^^^"
  echo "OpenAI should respond that it cannot answer math problems above"
  echo
done

# Step 6: Configure organization-level prompts
read -p "Step 6: Prepend or Append organization-level prompts using a RouteOption. Press enter to proceed..."
kubectl apply -f prompt-management/complete-override
echo
cat prompt-management/complete-override/*.yaml
echo
echo "RouteOption applied successfully."
echo

# Step 7: Test OpenAI endpoint
echo
echo "Testing OpenAI endpoint with a simple math question "what is 10+10?" with prompt injections applied"

while true; do
  read -p "Press Enter to send a request, or type 'next' to move on: " user_input
  if [[ "$user_input" == "next" ]]; then
    echo "Step 7 complete."
    echo
    break
  fi

  echo "Sending request to OpenAI endpoint..."
  curl http://$GATEWAY_IP:$AIGW_PORT/openai -H "Content-Type: application/json" -d '{
      "model": "gpt-4o-mini",
      "messages": [
        {
          "role": "user",
          "content": "What is 10+10?"
        }
      ]
    }'
  echo
  echo "^^^^"
  echo "OpenAI should respond with "i love lamp""
  echo
done


# Step 8: Cleanup
read -p "Step 8: Cleanup demo resources. Press enter to proceed..."
kubectl delete -f prompt-management/no-math
kubectl delete -f prompt-management/complete-override
kubectl delete -f route
echo "Cleanup completed."
echo

echo "END"