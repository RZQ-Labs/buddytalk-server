import chromadb
client = chromadb.Client()
collection_name = "default"
if collection_name not in client.list_collections():
    client.create_collection(collection_name)
