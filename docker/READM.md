# OpenSearch Docker Compose

opensearch docker


host의 메모리 사용량 증가
```shell
sudo sysctl -w vm.max_map_count=512000
```

인증서 생성
```shell
bash generate-certs.sh
```

Docker 실행
```shell
docker-compose up -d
```

security

```shell
docker-compose exec os-node1 bash -c "chmod +x plugins/opensearch-security/tools/securityadmin.sh && bash plugins/opensearch-security/tools/securityadmin.sh -cd config/opensearch-security -icl -nhnv -cacert config/certs/ca/ca.pem -cert config/certs/ca/admin.pem -key config/certs/ca/admin.key -h localhost"
```