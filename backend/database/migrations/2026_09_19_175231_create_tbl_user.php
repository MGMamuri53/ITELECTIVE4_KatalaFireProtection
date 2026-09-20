<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('tbl_user', function (Blueprint $table) {
            $table->bigIncrements('v_userId');

            $table->unsignedBigInteger('v_roleId')->nullable();
            $table->unsignedBigInteger('v_customerId')->nullable();

            $table->string('v_userName', 100)->unique();
            $table->string('v_passwordHash', 255)->nullable();

            $table->string('v_firstName', 100)->nullable();
            $table->string('v_lastName', 100)->nullable();

            $table->string('v_emailAddress', 150)->nullable()->unique();
            $table->string('v_mobileNumber', 30)->nullable();

            $table->string('v_accountStatus', 50)->nullable();

            $table->dateTime('v_lastLoginAt')->nullable();

            $table->boolean('v_isActive')->default(true);

            $table->dateTime('v_createdAt')->useCurrent();
            $table->dateTime('v_updatedAt')->useCurrent();

            $table->foreign('v_roleId', 'fk_user_role')
                ->references('v_roleId')
                ->on('tbl_role')
                ->onUpdate('cascade')
                ->onDelete('set null');

            $table->foreign('v_customerId', 'fk_user_customer')
                ->references('v_customerId')
                ->on('tbl_customer')
                ->onUpdate('cascade')
                ->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('tbl_user');
    }
};